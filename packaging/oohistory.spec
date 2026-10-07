Name:           oohistory
Version:        0.1.0
Release:        1%{?dist}
Summary:        Tamper-evident append-only shell command history with redaction of credential tokens.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oohistory
Source0:        oohistory-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oohistory is a sovereign, capability-bounded AUDIT LEDGER written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oohistory
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oohistory-uninstall

%files
/usr/bin/oohistory
/usr/bin/oohistory-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
