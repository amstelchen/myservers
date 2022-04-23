# Maintainer: Michael John <amstelchen at gmail dot com>

pkgname=myservers
_pkgname=myservers
pkgver=0.1.2
pkgrel=1
pkgdesc="A bash script for listing MySQL and MariaDB instances inside and outside a network."
arch=('any')
url="http://github.com/amstelchen/myservers"
license=('GPL')
packager=('Michael John')
depends=('bash' 'gettext' 'mariadb-clients')
optdepends=('yad')
makedepends=()
source=("${pkgname}_${pkgver}.tar.gz"::"https://github.com/amstelchen/myservers/archive/refs/tags/${pkgver}.tar.gz")
sha256sums=('fe778b5c533c7ca7d61d0472abd18cf56ec74562db2afea405cbf915ba10490d')

package() {
  install -Dm755 "${srcdir}/${_pkgname}-${pkgver}"/myservers.sh \
      "${pkgdir}"/usr/bin/myservers
  install -d "$pkgdir/usr/share/locale/de/LC_MESSAGES/"
  install -Dm644 "${srcdir}/${_pkgname}-${pkgver}"/po/de.mo \
      "${pkgdir}"/usr/share/locale/de/LC_MESSAGES/"${pkgname}.mo"
  install -d "$pkgdir/usr/share/myservers"
  install -Dm755 "${srcdir}/${_pkgname}-${pkgver}"/myservers.conf.SAMPLE \
      "${pkgdir}"/usr/share/myservers/
}
