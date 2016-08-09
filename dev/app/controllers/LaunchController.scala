package controllers

import play.api.mvc._
import play.api._
import play.api.Logger
import play.api.i18n._
import javax.inject.Inject
import models._
import play.api.data._
import play.api.data.Forms._
import scala.sys.process._
import java.util.Date
import java.io._
import java.text.SimpleDateFormat

class LaunchController @Inject() (val messagesApi:MessagesApi) extends Controller with I18nSupport  {
    
  private val BwaForm : Form[Bwa]=Form(mapping(                        
                                                "exe_name" -> nonEmptyText,
                                                "option1" -> nonEmptyText)(Bwa.apply)(Bwa.unapply)
                                                      ) 
 
  
  def home= Action{
    implicit request =>
      Ok(views.html.home())
  }
  
  def analysis = Action{
     implicit request =>
       Ok(views.html.bwa())
  }
  def launch =Action{
    implicit request =>
      val bwa=BwaForm.bindFromRequest()
       bwa.fold(
           hasErrors=> Ok("input error")
           , success= { newBwa=>           
                        
                          val useradd=Seq("sftp-useradd.sh","user1","1111")
                          Process(useradd).run
                          val now= (new SimpleDateFormat("yyyy-MM-dd-HH-mm")).format(new Date).toString()
                          val exe_name=bwa.data("exe_name")
                          val job_name=exe_name+"-"+now
                          val job_path="/nfsdir/"+job_name
                          val data_name= "MT.fa"
                          Process("mkdir "+job_path).run
                          Process("chmod 777 "+job_path).run    
                          Process("touch "+job_path+"/innerSh.sh").run
                          Process("touch "+job_path+"/Dockerfile").run
                          
                          val cmd=Bwa.getCmd(newBwa)
                          
                          writingInnerSh(job_path,exe_name,data_name,job_name,cmd+data_name )
                          writingDockerfile(job_path)
                          
                    
                          val launch=Seq("launch.sh",job_path,job_name)
                          Process(launch).run
                          
                          Ok(cmd)
           }
           )
  }  
  def sftpresult(data:String) = Action{
    implicit request =>
   
      val result=Seq("mv","-f","/nfsdir/"+data,"/home/user1")
      Process(result).run 
      Ok("ok")
       
      
  }
  
   private def writingDockerfile(file_path :String) = {
    val bw = new BufferedWriter(new FileWriter(file_path+"/Dockerfile"))
     bw.write("FROM ubuntu:latest")
     bw.newLine()
     bw.write("RUN apt-get update")
     bw.newLine()
     bw.write("RUN apt-get install -y curl")
     bw.newLine()
     bw.write("RUN apt-get install -y nfs-common")
     bw.newLine()
     bw.write("WORKDIR "+file_path+"/")
     bw.newLine()
     bw.write("CMD ./innerSh.sh")
     bw.close()
  }              
   private def writingInnerSh(file_path:String, exe_name:String, data_name:String, job_name:String, cmd:String)={
     val bw = new BufferedWriter(new FileWriter(file_path+"/innerSh.sh"))
     bw.write("#! /bin/sh")
     bw.newLine()
     bw.write("set -e")
     bw.newLine()
     bw.write("ln /nfsdir/"+exe_name+" "+file_path)
     bw.newLine()
     bw.write("ln /nfsdir/"+data_name+" "+file_path)
     bw.newLine()
     bw.write(cmd)
     bw.newLine()
     bw.write("rm "+exe_name)
     bw.newLine()
     bw.write("rm "+data_name)
     bw.newLine()
     bw.write("rm Dockerfile")
     bw.newLine()
     bw.write("rm docker.json")
     bw.newLine()
     bw.write("rm innerSh.sh")
     bw.newLine()
     bw.write("curl 211.249.63.201:9000/result/"+job_name)
     bw.newLine()
     bw.close()
     Process("sudo chmod 777 "+file_path+"/innerSh.sh").run
                       
   }
  
 
}