include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BelieveFTMods
BelieveFTMods_FILES = BelieveFTMods.xm
BelieveFTMods_FRAMEWORKS = UIKit
BelieveFTMods_PRIVATE_FRAMEWORKS = 
BelieveFTMods_CFLAGS = -fobjc-arc

# Target all installed apps; change to a specific bundle ID to narrow the scope
BelieveFTMods_BUNDLE_ID = *

include $(THEOS_MAKE_PATH)/tweak.mk
