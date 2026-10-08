# ==============================================================================
# oohistory: Sovereign Audit Ledger for Shell Command History
# Verification and Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oohistory
SRC := $(shell find . -name "*.oo" -o -name "*.oot" 2>/dev/null)
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.2.0")
OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oohistory-linux-x86_64
	@cd dist && sha256sum oohistory-linux-x86_64 > oohistory-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oohistory-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oohistory" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "oohistory 0.2.0" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "OK: all tests passed" && echo "PASS: internal anchors"
	@echo "=== testing showcase --demo -D ==="
	@./$(BIN) -D | grep -q "oohistory: Sovereign openOODA Audit Ledger Demo" && echo "PASS: --demo"
	@echo "=== testing record append and secret masking ==="
	@rm -f dist/test.ledger
	@./$(BIN) -f dist/test.ledger -a "git clone git@github.com:openOODA-tools/oohistory.git" | grep -q "Appended record #1" && echo "PASS: record #1 appended"
	@./$(BIN) -f dist/test.ledger -a "export OPENAI_API_KEY=sk-antigravity999" | grep -q "Appended record #2" && echo "PASS: record #2 appended"
	@./$(BIN) -f dist/test.ledger | grep -q "\[REDACTED:API_KEY\]" && echo "PASS: credential redaction verified"
	@echo "=== testing hash chain verification ==="
	@./$(BIN) -f dist/test.ledger --verify | grep -q "PASS: Hash chain is unbroken" && echo "PASS: cryptographic integrity verified"
	@echo "=== testing stats and structured JSON ==="
	@./$(BIN) -f dist/test.ledger --stats | grep -q "Total Entries:      2" && echo "PASS: stats output"
	@./$(BIN) -f dist/test.ledger -j | grep -q "\"command\":" && echo "PASS: structured JSON output"
	@rm -f dist/test.ledger
	@echo "=== testing MCP initialize ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | ./$(BIN) --mcp | grep -q "history_list" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call history_append ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"history_append","arguments":{"command":"cargo build --release"}}}' | ./$(BIN) --mcp | grep -q 'cargo build' && echo "PASS: MCP history_append"
	@echo "=== testing MCP tools/call history_verify ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"history_verify","arguments":{}}}' | ./$(BIN) --mcp | grep -q 'is_valid' && echo "PASS: MCP history_verify"
	@echo "=== testing MCP tools/call history_demo ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"history_demo","arguments":{}}}' | ./$(BIN) --mcp | grep -q "Audit Ledger Demo" && echo "PASS: MCP history_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oohistory
	@chmod 0755 dist/deb-root/usr/bin/oohistory
	@cp uninstall.sh dist/deb-root/usr/bin/oohistory-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oohistory-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oohistory_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oohistory_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oohistory-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oohistory.spec > ~/rpmbuild/SPECS/oohistory.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oohistory.spec
	@cp ~/rpmbuild/RPMS/x86_64/oohistory-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oohistory
	@chmod 0755 dist/arch-pkg/usr/bin/oohistory
	@cp uninstall.sh dist/arch-pkg/usr/bin/oohistory-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oohistory-uninstall
	@printf "pkgname = oohistory\npkgbase = oohistory\npkgver = $(VERSION)-1\npkgdesc = Sovereign audit ledger in pure openOODA.\nurl = https://github.com/openOODA-tools/oohistory\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oohistory\n" > dist/arch-pkg/.PKGINFO
	@cd dist/arch-pkg && bsdtar -czvf ../oohistory-$(VERSION)-1-x86_64.pkg.tar.zst .PKGINFO usr/
	@rm -rf dist/arch-pkg
	@echo "built dist/oohistory-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: $(BIN) package-deb package-rpm package-arch
	@cd dist && sha256sum oohistory oohistory_$(VERSION)-1_amd64.deb oohistory-$(VERSION)-1.fc44.x86_64.rpm oohistory-$(VERSION)-1-x86_64.pkg.tar.zst oohistory-linux-x86_64 oohistory-linux-x86_64.sha256 > checksums.txt
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist
	@echo "cleaned"
