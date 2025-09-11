#!/usr/bin/env bash
set -euo pipefail

# cores
RED=$'\033[1;31m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[1;34m'
RESET=$'\033[0m'

usage() {
cat <<EOF
Uso: $0 [-a|-r] pacote.tar.gz

Opções:
  -a    Append (padrão) - adiciona apenas arquivos inexistentes.
  -r    Replace - apaga o destino e substitui.
  -h    Mostrar este help.

Comportamento:
- Lê install.map (se existir) dentro do tar; formato: src=dst
  Ex.: hypr=\$HOME/.config
       Aux/script.sh=/bin
- Primeiro aplica os mapeamentos explícitos.
- Depois copia todo o restante preservando caminho relativo em / (ex.: Dir1/fileA -> /Dir1/fileA).
- install.map é ignorado na cópia.
EOF
}

# opções (padrão = append)
MODE="a"
while getopts "rah" opt; do
    case "$opt" in
        r) MODE="r" ;;
        a) MODE="a" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND-1))

# checar pacote
if [ "${1:-}" == "" ]; then
    echo -e "${RED}[ERRO]${RESET} Falta o arquivo tar.gz."
    usage
    exit 1
fi
TARFILE="$1"

# checar rsync
if command -v rsync >/dev/null 2>&1; then
    RSYNC=1
else
    RSYNC=0
fi

# tmp
TMPDIR=$(mktemp -d /tmp/install_XXXXXXXX)
echo -e "${BLUE}[INFO]${RESET} Usando diretório temporário: $TMPDIR"

# extrair
echo -e "${BLUE}[INFO]${RESET} Extraindo $TARFILE ..."
tar -xzf "$TARFILE" -C "$TMPDIR"
echo -e "${GREEN}[OK]${RESET} Extração concluída."

MAPFILE="$TMPDIR/install.map"
declare -A MAP

# ler mapa (se houver)
if [ -f "$MAPFILE" ]; then
    echo -e "${BLUE}[INFO]${RESET} Carregando install.map ..."
    while IFS='=' read -r SRC DST || [ -n "$SRC" ]; do
        # trim
        SRC=$(printf '%s' "$SRC" | xargs || true)
        DST=$(printf '%s' "$DST" | xargs || true)
        [ -z "$SRC" ] && continue
        [[ "$SRC" =~ ^# ]] && continue

        # ~ -> $HOME
        DST="${DST/#\~/$HOME}"

        # expande variáveis como $HOME, $XDG..., etc.
        if [ -n "$DST" ]; then
            # cuidado: eval usado para expandir variáveis; o arquivo está vindo do seu tar.
            eval "DST=\"$DST\""
        fi

        # se vazio, usa "/"
        [ -z "$DST" ] && DST="/"

        MAP["$SRC"]="$DST"
        echo -e "${YELLOW}  MAP:${RESET} $SRC -> $DST"
    done < "$MAPFILE"
else
    echo -e "${YELLOW}[AVISO]${RESET} Nenhum install.map encontrado; tudo não mapeado vai para / (padrão)."
fi

# função utilitária: verifica se dado REL está coberto por algum mapa (igual ou prefixo)
is_mapped() {
    local rel="$1"
    for key in "${!MAP[@]}"; do
        if [ "$key" = "/" ]; then
            return 0
        fi
        if [ "$rel" = "$key" ]; then
            return 0
        fi
        case "$rel" in
            "$key"/*) return 0 ;;
        esac
    done
    return 1
}

# processa mapeamentos explícitos primeiro
echo -e "${BLUE}[INFO]${RESET} Aplicando mapeamentos explícitos..."
for key in "${!MAP[@]}"; do
    # fonte no tmp (chave "/" significa root do pacote)
    if [ "$key" = "/" ]; then
        SRC_PATH="$TMPDIR"
    else
        SRC_PATH="$TMPDIR/$key"
    fi

    DST_BASE="${MAP[$key]}"
    if [ ! -e "$SRC_PATH" ]; then
        echo -e "${YELLOW}[AVISO]${RESET} Origem do mapa não encontrada: $key (esperado em $SRC_PATH), pulando."
        continue
    fi

    if [ -d "$SRC_PATH" ]; then
        # diretório: copiar conteúdo do SRC_PATH para DST_BASE
        if [ "$MODE" = "r" ]; then
            echo -e "${GREEN}[MAPPED -R]${RESET} $key -> $DST_BASE (dir, substituindo)"
            rm -rf "$DST_BASE"
            mkdir -p "$DST_BASE"
            if [ "$RSYNC" -eq 1 ]; then
                rsync -a --delete "${SRC_PATH%/}/" "${DST_BASE%/}/"
            else
                # fallback cp
                cp -a "${SRC_PATH%/}/." "$DST_BASE/"
            fi
        else
            echo -e "${GREEN}[MAPPED -A]${RESET} $key -> $DST_BASE (dir, append)"
            mkdir -p "$DST_BASE"
            if [ "$RSYNC" -eq 1 ]; then
                rsync -a --ignore-existing "${SRC_PATH%/}/" "${DST_BASE%/}/"
            else
                cp -rn "${SRC_PATH%/}/." "$DST_BASE/" 2>/dev/null || true
            fi
        fi
    else
        # arquivo: copiar arquivo para dentro do DST_BASE (tratamos DST_BASE como diretório destino)
        mkdir -p "$DST_BASE"
        destfile="$DST_BASE/$(basename "$SRC_PATH")"
        if [ "$MODE" = "r" ]; then
            echo -e "${GREEN}[MAPPED -R]${RESET} $key -> $destfile (file, substituindo)"
            rm -f "$destfile"
            cp -a "$SRC_PATH" "$destfile"
        else
            if [ ! -e "$destfile" ]; then
                echo -e "${GREEN}[MAPPED -A]${RESET} $key -> $destfile (file, adicionando)"
                cp -a "$SRC_PATH" "$destfile"
            else
                echo -e "${YELLOW}[IGNORADO]${RESET} $destfile já existe (append)"
            fi
        fi
    fi
done

# agora copia todo o restante que NÃO está mapeado (preservando caminho relativo em /)
echo -e "${BLUE}[INFO]${RESET} Copiando itens não mapeados (preservando caminho relativo em /)..."
# iterar recursivamente, mas pular tudo que é coberto por mapa
while IFS= read -r -d '' ITEM; do
    REL=$(realpath --relative-to="$TMPDIR" "$ITEM")
    # pular o install.map
    [ "$REL" = "install.map" ] && continue

    # pular tudo que está mapeado (igual ou abaixo de uma chave mapeada)
    if is_mapped "$REL"; then
        continue
    fi

    DST="/$REL"
    # se for diretório, queremos copiar conteúdo para /REL
    if [ -d "$ITEM" ]; then
        echo -e "${GREEN}[DEFAULT]${RESET} $REL -> $DST/ (dir)"
        mkdir -p "$DST"
        if [ "$RSYNC" -eq 1 ]; then
            rsync -a "${ITEM%/}/" "${DST%/}/"
        else
            cp -a "${ITEM%/}/." "$DST/"
        fi
    else
        # arquivo
        mkdir -p "$(dirname "$DST")"
        if [ "$MODE" = "r" ]; then
            echo -e "${GREEN}[DEFAULT -R]${RESET} $REL -> $DST (file, substituindo)"
            rm -f "$DST"
            cp -a "$ITEM" "$DST"
        else
            if [ ! -e "$DST" ]; then
                echo -e "${GREEN}[DEFAULT -A]${RESET} $REL -> $DST (file, adicionando)"
                cp -a "$ITEM" "$DST"
            else
                echo -e "${YELLOW}[IGNORADO]${RESET} $DST já existe (append)"
            fi
        fi
    fi
done < <(find "$TMPDIR" -mindepth 1 -print0)

# limpeza
rm -rf "$TMPDIR"
echo -e "${GREEN}[FINALIZADO]${RESET} Instalação concluída."

