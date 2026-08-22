include $(TOPDIR)/rules.mk

PKG_NAME:=unetic-core
PKG_VERSION:=0.2.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/unetic-core
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Unetic control-plane daemon
  URL:=https://github.com/Unetic/unetic-core
  DEPENDS:=+rpcd +libubus +libubox +libblobmsg-json +ip-full +tc-full +iptables-nft +sqm-scripts +usteer +wpad-mbedtls
endef

define Package/unetic-core/description
  Unetic control-plane daemon for OpenWrt.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/source/. $(PKG_BUILD_DIR)/ || true
endef

define Package/unetic-core/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/usr/share/rpcd/acl.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-binary $(1)/usr/sbin/unetic-core
	$(INSTALL_BIN) $(CURDIR)/files/unetic-core.init $(1)/etc/init.d/unetic-core
	$(INSTALL_DATA) $(CURDIR)/files/unetic.json $(1)/usr/share/rpcd/acl.d/unetic.json
endef

$(eval $(call BuildPackage,unetic-core))
