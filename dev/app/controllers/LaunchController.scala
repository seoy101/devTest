package controllers

import play.api.mvc._
import play.api._
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
           , success=> {           
                  // val job_name ="bwa-"+bwa.data("job_name")+"-"+(new Date).toString()
                  // val cmd =Seq("mkdir", "/home/user1/"+job_name)
                  // Process(cmd).run
                    //  cd data to directory
             ///////////////adduser + create directory +Dockerfile,innersh.sh + chmod//////////////////////
                      /*    var cmd = "./"
                          bwa.data.keys.foreach{
                                  option => cmd+=bwa.data(option)+" "
                              }
                          cmd+="MT.fa"
                          writingInnerSh("/home/user1/bwa", cmd)
                          writingDockerfile("/home/user1/bwa")
                          Process("sudo chmod 777 /home/user1/bwa").run
                          Process("sudo chmod 777 /home/user1/bwa/Dockerfile").run
                          Process("sudo chmod 777 /home/user1/bwa/innerSh.sh").run
                          val launch =Seq("launch.sh","/home/user1/bwa",bwa.data("job_name")+"-"+(new Date).toString())
                          
                          Process(launch).run()*/
             
                          val useradd=Seq("sftp-useradd.sh","user1","1111")
                          Process(useradd).run
                          val now= (new SimpleDateFormat("yyyy-MM-dd-hh")).format(new Date).toString()
                          val exe_name=bwa.data("exe_name")
                          val job_name=exe_name+"-"+now
                          val job_path="/nfsdir/"+job_name
                          val data_name= "MT.fa"
                          Process("sudo mkdir "+job_path).run
                          Process("sudo chmod 777 "+job_path).run    
                          
                          var cmd = "./"
                          bwa.data.keys.foreach{
                                  option => cmd+=bwa.data(option)+" "
                              }
                          cmd+=data_name
                          writingInnerSh(job_path,exe_name,data_name,job_name,cmd)
                          writingDockerfile(job_path)
                          
                    
                          val launch=Seq("launch.sh",job_path,job_name)
                          Process(launch).run
                          
                          Ok(job_path)
           }
           )
  }  
  def sftpresult(data:String) = Action{
    implicit request =>
   
 //      data.split("|").foreach(file => Process("cp -r /nfsdir/"+file+" /home/user1/").run)
      val result=Seq("mv","-f",data,"/home/user1")
      Process(result).run 
      Ok("ok")
       
      
  }
  
   private def writingDockerfile(file_path :String) = {
    val bw = new BufferedWriter(new FileWriter(file_path+"/Dockerfile"))
     bw.write("FROM ubuntu:latest")
     bw.newLine()
    /* bw.write("ADD innerSh.sh /tmp")/////추후수정 nfs쓰면 add안해줌
     bw.newLine()
     bw.write("ADD MT.fa /tmp")////ddd
     bw.newLine()*/
     
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
   //  bw.write("val=$(ls -I MT.fa -I bwa -I bwa-yyyy-mm-dd)")
   //  bw.newLine()
   //  bw.write("result=$(echo $val|tr ' ' '|')")
    // bw.newLine()
    // bw.write("curl 175.158.15.45:9000/result/$result")
   //  bw.newLine()
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
     bw.write("curl 175.158.15.45:9000/result/"+job_name)
     bw.newLine()
    // bw.newLine()
     /////////curl 추가 
     bw.close()
     Process("sudo chmod 777 "+file_path+"/innerSh.sh").run
                       
   }
  
 
}