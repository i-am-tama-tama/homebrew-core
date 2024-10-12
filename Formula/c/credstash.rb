class Credstash < Formula
  include Language::Python::Virtualenv

  desc "Little utility for managing credentials in the cloud"
  homepage "https://github.com/fugue/credstash"
  url "https://files.pythonhosted.org/packages/b4/89/f929fda5fec87046873be2420a4c0cb40a82ab5e30c6d9cb22ddec41450b/credstash-1.17.1.tar.gz"
  sha256 "6c04e8734ef556ab459018da142dd0b244093ef176b3be5583e582e9a797a120"
  license "Apache-2.0"
  revision 11
  head "https://github.com/fugue/credstash.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "fa89e1522664771ab0dbecce55ad9dc9bdec04cc7de4f30fbbb5d8e4b37927aa"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "4cb0bd612b75c05fd66fb6651c7f2ac6fad78f196f23abb9759766230bcd498b"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "4cb0bd612b75c05fd66fb6651c7f2ac6fad78f196f23abb9759766230bcd498b"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4cb0bd612b75c05fd66fb6651c7f2ac6fad78f196f23abb9759766230bcd498b"
    sha256 cellar: :any_skip_relocation, sonoma:         "a90433b657261082ecf6b44ffebe48c035af0aa7e3f3f9daeaa7d4f3dff1666b"
    sha256 cellar: :any_skip_relocation, ventura:        "a90433b657261082ecf6b44ffebe48c035af0aa7e3f3f9daeaa7d4f3dff1666b"
    sha256 cellar: :any_skip_relocation, monterey:       "4cb0bd612b75c05fd66fb6651c7f2ac6fad78f196f23abb9759766230bcd498b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "adad563a426ca4094cc267f4d29b72122c0ad2dc60353269468f9713dc28778f"
  end

  depends_on "cryptography"
  depends_on "python@3.13"

  resource "boto3" do
    url "https://files.pythonhosted.org/packages/b8/29/10988ceaa300ddc628cb899875d85d9998e3da4803226398e002d95b2741/boto3-1.35.39.tar.gz"
    sha256 "670f811c65e3c5fe4ed8c8d69be0b44b1d649e992c0fc16de43816d1188f88f1"
  end

  resource "botocore" do
    url "https://files.pythonhosted.org/packages/f7/28/d83dbd69d7015892b53ada4fded79a5bc1b7d77259361eb8302f88c2da81/botocore-1.35.39.tar.gz"
    sha256 "cb7f851933b5ccc2fba4f0a8b846252410aa0efac5bfbe93b82d10801f5f8e90"
  end

  resource "jmespath" do
    url "https://files.pythonhosted.org/packages/00/2a/e867e8531cf3e36b41201936b7fa7ba7b5702dbef42922193f05c8976cd6/jmespath-1.0.1.tar.gz"
    sha256 "90261b206d6defd58fdd5e85f478bf633a2901798906be2ad389150c5c60edbe"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz"
    sha256 "37dd54208da7e1cd875388217d5e00ebd4179249f90fb72437e91a35459a0ad3"
  end

  resource "s3transfer" do
    url "https://files.pythonhosted.org/packages/a0/a8/e0a98fd7bd874914f0608ef7c90ffde17e116aefad765021de0f012690a2/s3transfer-0.10.3.tar.gz"
    sha256 "4f50ed74ab84d474ce614475e0b8d5047ff080810aac5d01ea25231cfc944b0c"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/ed/63/22ba4ebfe7430b76388e7cd448d5478814d3032121827c12a2cc287e2260/urllib3-2.2.3.tar.gz"
    sha256 "e7d814a81dad81e6caf2ec9fdedb284ecc9c73076b62654547cc64ccdcae26e9"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    ENV["AWS_ACCESS_KEY_ID"] = "test"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test"
    output = shell_output("#{bin}/credstash put test test 2>&1", 1)
    assert_match "Could not generate key using KMS key", output
  end
end
