include $(TOPDIR)/rules.mk

PKG_NAME:=unetic-cli
PKG_VERSION:=$(shell sed -n 's/^version = "\([^"]*\)"/\1/p' $(CURDIR)/source/Cargo.toml | head -n1)
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

PKG_BUILD_DEPENDS:=rust/host
RUST_PKG_LOCKED:=1

define Package/unetic-cli
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Unetic CLI
  URL:=https://github.com/Unetic/unetic-cli
  DEPENDS:=+ubus
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/source/. $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Cargo)
endef

define Package/unetic-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/unetic $(1)/usr/bin/unetic
endef

$(eval $(call BuildPackage,unetic-cli))
