#!/system/bin/sh

export ANDROID_ROOT=/system
export ANDROID_DATA=/system
export ANDROID_STORAGE=/storage
export PYTHONHOME=/acestream.engine/python
export PYTHONPATH=/acestream.engine/python/lib/python2.7/lib-dynload
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/acestream.engine/python/lib:/acestream.engine/python/lib/python2.7/lib-dynload
export PATH=$PYTHONHOME/bin:$PATH
/acestream.engine/python/bin/python
