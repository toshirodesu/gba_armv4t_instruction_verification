
# Envirmental Settings -------------

COMPILER_DIR = /home/tool/arm-none-eabi-gcc/bin
STM32LIB_DIR = /home/tool/STM32F407Lib

# ----------------------------------

CC      = $(COMPILER_DIR)/arm-none-eabi-gcc
CXX     = $(COMPILER_DIR)/arm-none-eabi-g++
ASM     = $(COMPILER_DIR)/arm-none-eabi-as
LINK    = $(COMPILER_DIR)/arm-none-eabi-g++
OBJCOPY = $(COMPILER_DIR)/arm-none-eabi-objcopy

# Libraries ------------------------

STM32LIB_INCLUDE  = -I$(STM32LIB_DIR)/Drivers/CMSIS/Include
STM32LIB_INCLUDE += -I$(STM32LIB_DIR)/Drivers/CMSIS/Device/ST/STM32F4xx/Include
STM32LIB_INCLUDE += -I$(STM32LIB_DIR)/Drivers/STM32F4xx_HAL_Driver/Inc
STM32LIB_INCLUDE += -I$(STM32LIB_DIR)/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy
# STM32LIB_INCLUDE += -I$(STM32LIB_DIR)/Utilities/STM32F4-Discovery

vpath %.c $(STM32LIB_DIR)/Drivers/STM32F4xx_HAL_Driver/Src
STM32LIB_SRC  = stm32f4xx_hal_tim.c stm32f4xx_hal_tim_ex.c stm32f4xx_hal_rcc.c stm32f4xx_hal_rcc_ex.c stm32f4xx_hal_flash.c stm32f4xx_hal_flash_ex.c
STM32LIB_SRC += stm32f4xx_hal_flash_ramfunc.c stm32f4xx_hal_gpio.c stm32f4xx_hal_dma_ex.c stm32f4xx_hal_dma.c stm32f4xx_hal_pwr.c stm32f4xx_hal_pwr_ex.c
STM32LIB_SRC += stm32f4xx_hal_cortex.c stm32f4xx_hal.c stm32f4xx_hal_exti.c
# vpath %.c $(STM32LIB_DIR)/Utilities/STM32F4-Discovery
# STM32LIB_SRC += stm32f4_discovery.c

# ----------------------------------

# Project Settings -----------------

APP_NAME     = gbainsver
BUILD_DIR    = ./build
SRC_DIR      = ./src
INCLUDE_DIR  = ./src
STARTUP_PATH = ./src/startup_stm32f407xx.s
LINKER_PATH  = ./src/stm32f407zgtx_flash.ld

SRCS  = $(SRC_DIR)/main.cpp
SRCS += $(STARTUP_PATH) $(SRC_DIR)/stm32f4xx_it.c $(SRC_DIR)/stm32f4xx_hal_msp.c $(SRC_DIR)/system_stm32f4xx.c
SRCS += $(STM32LIB_SRC)
OBJS  = $(SRCS:.c=.o)

# ----------------------------------

# Compiling Flags ------------------

CXXFLAGS  = -g -O2 -Wall -std=c++17 -T $(LINKER_PATH)
CXXFLAGS += -DUSE_HAL_DRIVER -DSTM32F407xx
CXXFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CXXFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CXXFLAGS += $(STM32LIB_INCLUDE) -I$(INCLUDE_DIR) -lc -lm -lnosys -specs=nosys.specs -Wl,-Map,$(BUILD_DIR)/$(APP_NAME).map,--cref -Wl,--gc-sections

# ----------------------------------

.PHONY: all clean

all: $(BUILD_DIR)/$(APP_NAME).elf

$(BUILD_DIR)/$(APP_NAME).elf: $(SRCS)
	$(CXX) $(CXXFLAGS) $^ -o $@ 
	$(OBJCOPY) -O ihex $(BUILD_DIR)/$(APP_NAME).elf $(BUILD_DIR)/$(APP_NAME).hex
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(APP_NAME).elf $(BUILD_DIR)/$(APP_NAME).bin

clean:
	-rm $(BUILD_DIR)/*.o
	-rm $(BUILD_DIR)/*.elf
	-rm $(BUILD_DIR)/*.map
	-rm $(BUILD_DIR)/*.bin
	-rm $(BUILD_DIR)/*.hex