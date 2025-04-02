# Maintainer: Your Name <your.email@domain.com>
pkgname=hyprland-screenshot
pkgver=1.0.0
pkgrel=1
pkgdesc="A Hyprland-specific screenshot tool using grim, slurp, wl-copy, and hyprctl"
arch=('any')
url="https://github.com/yourusername/hyprland-screenshot"
license=('MIT')
depends=('grim' 'slurp' 'wl-clipboard' 'hyprland')
optdepends=(
  'jq: for parsing JSON from hyprctl'
  'libnotify: for notifications'
  'canberra-gtk-play: for camera shutter sounds'
)
source=("${pkgname}.sh")
sha256sums=('SKIP')  # Use makepkg -g to generate the real one

package() {
  install -Dm755 "${srcdir}/${pkgname}.sh" "${pkgdir}/usr/bin/${pkgname}"
}

sha256sums=('6ff6adca6f17368c778dd3eb6796f85f5d0abf2f067e41edee3af8b1670a851a')
