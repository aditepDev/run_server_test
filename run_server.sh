#!/bin/sh

PROJECT_NAME="project_test"
PATH_GIT="/Users/user/git/$PROJECT_NAME"
PATH_JAR="$PATH_GIT/target/project_test-0.0.1-SNAPSHOT.jar"
PATH_JAR_LOG="$PATH_GIT/target/log.txt"
PATH_SCRIPT="$PATH_GIT/target/script"
PATH_SCRIPT_BUILD_LOG="$PATH_GIT/target/script/log.txt"
changed=0

shotdown(){
     echo "shotdown $(cat ./pid.file) "  
     kill -9 $(cat ./pid.file) 
}
 
startup(){
     echo "run $PATH_JAR > $PATH_JAR_LOG"
     nohup java -jar $PATH_JAR  > $PATH_JAR_LOG 2>&1 &
     echo $! >./pid.file 
}

build(){
     echo "build"
     nohup mvn install > $PATH_SCRIPT_BUILD_LOG 2>&1 & 
}


check_run(){

echo check run... 30s $PID
sleep 30
PID=$(cat ./pid.file)
number=$(ps aux | grep -v grep | grep -ci $PID  )
echo "#################################"
jps
echo "#################################"
# if  (($number != 1));
if ps -p $PID > /dev/null;
then
    echo $PID  ok..
else 
    echo  run again...!!
    startup
    check_run
fi
}




main(){
echo "$PROJECT_NAME --- : start"
echo "$PROJECT_NAME --- : git check update"
cd $PATH_GIT
git remote update && git status -uno | grep -q 'Your branch is behind' && changed=1
if [ $changed = 1 ]; then
     echo "$PROJECT_NAME --- : git pull"
     git pull
     build
     cd $PATH_SCRIPT
     shotdown
     startup
     echo "Updated successfully";
else
    echo "Up-to-date"
fi   
    cd $PATH_SCRIPT
     check_run
     echo "$PROJECT_NAME --- : end"
}


if [ $# -eq 0 ]
  then
    main_run
  else
          if [ "$1" = "re" ]; then
          cd $PATH_PROJECT
          shotdown
          echo "startup"  
          startup
          fi
          if [ "$1" = "pull" ]; then
          cd $PATH_GIT
          echo "$PROJECT_NAME --- : git pull"
          git pull
          fi
          if [ "$1" = "run" ]; then
          cd $PATH_GIT
          echo "$PROJECT_NAME --- : git pull"
          git pull
          build
          cd $PATH_PROJECT
          shotdown
          startup
          cd $PATH_PROJECT
          check_run
          fi
fi
