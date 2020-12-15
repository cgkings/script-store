#! /bin/bash
printUsage(){
    echo "usage: test.sh -i <filename> -o <filename> [args...]"
    exit -1
}
if [ $# -eq 0 ];then
    printUsage
fi
while getopts :hi:o: opts;do
    case "$opts" in
        i)
            inputfile=$OPTARG
            if [ ! -f $inputfile ];then
                echo "The input file $inputfile doesn't exist!"
                exit -1
            fi
            ;;
        o)
            outputfile=$OPTARG
            ;;
        h)
            printUsage
            ;;
        :)
            echo "$0 must supply an argument to option -$OPTARG!"
            printUsage
            ;;
        ?)
            echo "invalid option -$OPTARG ignored!"
            printUsage
            ;;
    esac
done
if [ -z "$outputfile" ];then
    printUsage
    exit -1
fi
echo "inputfile:$inputfile
outputfile:$outputfile"
 
shift $(($OPTIND-1));
 
if [ $# -gt 0 ];then
    echo "other arguments:$@";
fi
————————————————
版权声明：本文为CSDN博主「_荣耀之路_」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/asty9000/java/article/details/87982509