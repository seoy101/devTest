package models


case class Bwa (exe_name: String , option1: String)

object Bwa{
  def getCmd(bwa:Bwa):String={
    val cmd = "./"+bwa.exe_name+" "+bwa.option1+" "
    return cmd
  }
}
  

