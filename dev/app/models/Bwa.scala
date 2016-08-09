package models


case class Bwa (exe_name: String , option1: String)
  
object Bwa {
  var cmd="./"
  def createCmd(option:String)={
    cmd=cmd+option+" "
  }
  
}
