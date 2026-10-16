BOARD=esp32s3
CHIP=esp32
PORT ?= /dev/ttyACM0

ALIBS=${HOME}/Arduino/libraries
EXCLUDE_DIRS=${ALIBS}/lvgl|${ALIBS}/LovyanGFX|${ALIBS}/esp32csim|${ALIBS}/PubSubClient/tests|${ALIBS}/U8g2/sys
#PART_FILE=partitions.csv
#FLASH_DEF=8M
GIT_VERSION := "$(shell git describe --abbrev=6 --dirty --always)"
ARDUINO_LIBS=${HOME}/Arduino/libraries

#CDC_ON_BOOT=1
#BUILD_EXTRA_FLAGS += -DBOARD_HAS_PSRAM 
BUILD_MEMORY_TYPE=qio_qspi
UPLOAD_PORT ?= ${PORT}

PART_FILE=${ESP_ROOT}/tools/partitions/min_spiffs.csv
BUILD_EXTRA_FLAGS += -DARDUINO_PARTITION_min_spiffs 

BUILD_EXTRA_FLAGS += -DGIT_VERSION=\"$(GIT_VERSION)\" -O1
BUILD_EXTRA_FLAGS += -mno-serialize-volatile
BUILD_EXTRA_FLAGS += ${DEF}

#sed  's|^\(.*/srmodels.bin\)|#\1|g' -i ~/.arduino15/packages/esp32/hardware/esp32/3.2.0/boards.txt  
#
csim-build:
	${MAKE} BOARD=csim csim 

ifeq ($(BOARD),csim)
CSIM_BUILD_DIR=./build/csim
CSIM_INC=-I./littlefs
CSIM_SRC_DIRS=./littlefs
include ${ALIBS}/esp32csim/csim.mk



else
include ${ALIBS}/makeEspArduino/makeEspArduino.mk
#include ../makeEspArduino/makeEspArduino.mk
endif
RATE=4800
1cat:
	stty -F ${PORT} -echo raw ${RATE} && cat ${PORT} 
cat:    
	while sleep .01; do if [ -c ${PORT} ]; then stty -F ${PORT} -echo raw ${RATE} && cat ${PORT}; fi; done  | tee ./cat.`basename ${PORT}`.out
uc:	
	${MAKE} upload && ${MAKE} cat

backtrace:
	tr ' ' '\n' | addr2line -f -i -e ./build/${BOARD}/*.elf
