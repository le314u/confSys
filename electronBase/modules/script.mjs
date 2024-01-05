class Script{
    constructor(name,about,path){
      this.name = name;
      this.about = about;
      this.path = path;
    }
    getName(){return this.name}
    getAbout(){return this.about}
    getPath(){return this.path}
}

export default Script;
