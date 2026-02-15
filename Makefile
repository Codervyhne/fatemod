TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = AnimalCompany
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FateMod

FateMod_FILES = Tweak.xm FateModMenu.m
FateMod_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
FateMod_FRAMEWORKS = UIKit QuartzCore AudioToolbox Foundation
FateMod_LDFLAGS = -ldl

include $(THEOS_MAKE_PATH)/tweak.mk
