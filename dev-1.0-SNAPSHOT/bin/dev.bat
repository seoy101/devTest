@REM dev launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM DEV_config.txt found in the DEV_HOME.
@setlocal enabledelayedexpansion

@echo off

if "%DEV_HOME%"=="" set "DEV_HOME=%~dp0\\.."

set "APP_LIB_DIR=%DEV_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%DEV_HOME%\DEV_config.txt"
set CFG_OPTS=
if exist %CFG_FILE% (
  FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%CFG_FILE%") DO (
    set DO_NOT_REUSE_ME=%%i
    rem ZOMG (Part #2) WE use !! here to delay the expansion of
    rem CFG_OPTS, otherwise it remains "" for this loop.
    set CFG_OPTS=!CFG_OPTS! !DO_NOT_REUSE_ME!
  )
)

rem We use the value of the JAVACMD environment variable if defined
set _JAVACMD=%JAVACMD%

if "%_JAVACMD%"=="" (
  if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running dev.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)


rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

:param_loop
call set _PARAM1=%%1
set "_TEST_PARAM=%~1"

if ["!_PARAM1!"]==[""] goto param_afterloop


rem ignore arguments that do not start with '-'
if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
set _APP_ARGS=!_APP_ARGS! !_PARAM1!
shift
goto param_loop

:param_java_check
if "!_TEST_PARAM:~0,2!"=="-J" (
  rem strip -J prefix
  set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
  shift
  goto param_loop
)

if "!_TEST_PARAM:~0,2!"=="-D" (
  rem test if this was double-quoted property "-Dprop=42"
  for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
    if not ["%%H"] == [""] (
      set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
    ) else if [%2] neq [] (
      rem it was a normal property: -Dprop=42 or -Drop="42"
      call set _PARAM1=%%1=%%2
      set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      shift
    )
  )
) else (
  if "!_TEST_PARAM!"=="-main" (
    call set CUSTOM_MAIN_CLASS=%%2
    shift
  ) else (
    set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  )
)
shift
goto param_loop
:param_afterloop

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!
:run
 
set "APP_CLASSPATH=%APP_LIB_DIR%\..\conf\;%APP_LIB_DIR%\dev.dev-1.0-SNAPSHOT-sans-externalized.jar;%APP_LIB_DIR%\com.typesafe.play.twirl-api_2.11-1.1.1.jar;%APP_LIB_DIR%\org.apache.commons.commons-lang3-3.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-server_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.build-link-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-exceptions-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-iteratees_2.11-2.5.4.jar;%APP_LIB_DIR%\org.scala-stm.scala-stm_2.11-0.7.jar;%APP_LIB_DIR%\com.typesafe.config-1.3.0.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.1.7.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.1.7.jar;%APP_LIB_DIR%\com.typesafe.play.play-json_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-functional_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-datacommons_2.11-2.5.4.jar;%APP_LIB_DIR%\joda-time.joda-time-2.9.2.jar;%APP_LIB_DIR%\org.joda.joda-convert-1.8.1.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.11.7.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.7.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jdk8-2.7.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jsr310-2.7.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-netty-utils-2.5.4.jar;%APP_LIB_DIR%\org.slf4j.jul-to-slf4j-1.7.19.jar;%APP_LIB_DIR%\org.slf4j.jcl-over-slf4j-1.7.19.jar;%APP_LIB_DIR%\com.typesafe.play.play-streams_2.11-2.5.4.jar;%APP_LIB_DIR%\org.reactivestreams.reactive-streams-1.0.0.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-stream_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.11.8.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-actor_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-java8-compat_2.11-0.7.0.jar;%APP_LIB_DIR%\com.typesafe.ssl-config-akka_2.11-0.2.1.jar;%APP_LIB_DIR%\com.typesafe.ssl-config-core_2.11-0.2.1.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-parser-combinators_2.11-1.0.4.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-slf4j_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\commons-codec.commons-codec-1.10.jar;%APP_LIB_DIR%\xerces.xercesImpl-2.11.0.jar;%APP_LIB_DIR%\xml-apis.xml-apis-1.4.01.jar;%APP_LIB_DIR%\javax.transaction.jta-1.1.jar;%APP_LIB_DIR%\com.google.inject.guice-4.0.jar;%APP_LIB_DIR%\javax.inject.javax.inject-1.jar;%APP_LIB_DIR%\aopalliance.aopalliance-1.0.jar;%APP_LIB_DIR%\com.google.inject.extensions.guice-assistedinject-4.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-netty-server_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.netty.netty-reactive-streams-http-1.0.6.jar;%APP_LIB_DIR%\com.typesafe.netty.netty-reactive-streams-1.0.6.jar;%APP_LIB_DIR%\io.netty.netty-handler-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-buffer-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-common-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-http-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-native-epoll-4.0.36.Final-linux-x86_64.jar;%APP_LIB_DIR%\com.typesafe.play.play-logback_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc-api_2.11-2.5.4.jar;%APP_LIB_DIR%\com.jolbox.bonecp-0.8.0.RELEASE.jar;%APP_LIB_DIR%\com.zaxxer.HikariCP-2.4.3.jar;%APP_LIB_DIR%\com.googlecode.usc.jdbcdslog-1.0.6.2.jar;%APP_LIB_DIR%\com.h2database.h2-1.4.191.jar;%APP_LIB_DIR%\tyrex.tyrex-1.0.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-cache_2.11-2.5.4.jar;%APP_LIB_DIR%\net.sf.ehcache.ehcache-core-2.6.11.jar;%APP_LIB_DIR%\com.typesafe.play.play-ws_2.11-2.5.4.jar;%APP_LIB_DIR%\com.google.guava.guava-19.0.jar;%APP_LIB_DIR%\org.asynchttpclient.async-http-client-2.0.2.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-resolver-dns-2.0.2.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-resolver-2.0.2.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.21.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-codec-dns-2.0.2.jar;%APP_LIB_DIR%\org.javassist.javassist-3.20.0-GA.jar;%APP_LIB_DIR%\oauth.signpost.signpost-core-1.2.1.2.jar;%APP_LIB_DIR%\oauth.signpost.signpost-commonshttp4-1.2.1.2.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpcore-4.0.1.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpclient-4.0.1.jar;%APP_LIB_DIR%\commons-logging.commons-logging-1.1.1.jar;%APP_LIB_DIR%\org.webjars.bootstrap-3.1.1-2.jar;%APP_LIB_DIR%\org.webjars.jquery-1.11.1.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-agent_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-camel_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\org.apache.camel.camel-core-2.13.4.jar;%APP_LIB_DIR%\com.sun.xml.bind.jaxb-impl-2.2.6.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-cluster_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-remote_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-protobuf_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\io.netty.netty-3.10.6.Final.jar;%APP_LIB_DIR%\org.uncommons.maths.uncommons-maths-1.2.2a.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-cluster-metrics_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-cluster-sharding_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-persistence_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-cluster-tools_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-contrib_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-core_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-parsing_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-testkit_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-stream-testkit_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-testkit_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-multi-node-testkit_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-osgi_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\org.osgi.org.osgi.core-4.3.1.jar;%APP_LIB_DIR%\org.osgi.org.osgi.compendium-4.3.1.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-persistence-tck_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\org.scalatest.scalatest_2.11-2.2.4.jar;%APP_LIB_DIR%\junit.junit-4.12.jar;%APP_LIB_DIR%\org.hamcrest.hamcrest-core-1.3.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-distributed-data-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-typed-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-jackson-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.7.4.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.7.4.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-spray-json-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\io.spray.spray-json_2.11-1.3.2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-xml-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-xml_2.11-1.0.5.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-persistence-query-experimental_2.11-2.4.9-RC2.jar;%APP_LIB_DIR%\dev.dev-1.0-SNAPSHOT-assets.jar"
set "APP_MAIN_CLASS=play.core.server.ProdServerStart"

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !DEV_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal


:end

exit /B %ERRORLEVEL%
