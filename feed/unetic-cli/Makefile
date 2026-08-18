include $(TOPDIR)/rules.mk

PKG_NAME:=unetic-cli
PKG_VERSION:=$(strip $(shell cat $(CURDIR)/source/VERSION))
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/unetic-cli
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Unetic CLI
  URL:=https://github.com/Unetic/unetic-cli
  DEPENDS:=+ubus
endef

define Package/unetic-cli/description
  Local terminal interface for the Unetic control plane.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/source/. $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/unetic-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-binary $(1)/usr/bin/unetic
endef

$(eval $(call BuildPackage,unetic-cli))
