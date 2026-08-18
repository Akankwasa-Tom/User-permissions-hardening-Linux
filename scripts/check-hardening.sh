#!/bin/bash
#========================================================================
#Server hardening verification script
#Project: User & Permission Hardening lab
#========================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo -e "${GREEN}[PASS]${NC} $label"
    ((PASS++))
  else
    echo -e "${RED}[FAIL]${NC} $label"
    ((FAIL++))
  fi
}


echo ""
echo "=============================="
echo " Hardening Verification Report"
echo "=============================="
echo ""

check "SSH running on port 222" \
  "grep -q 'Port 222' /etc/ssh/sshd_config"

check "Root SSH login disabled" \
  "grep -q 'PermitRootLogin no' /etc/ssh/sshd_config"

check "Password auth disabled" \
  "grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config"

check "Pubkey auth enabled" \
  "grep -q 'PubkeyAuthentication yes' /etc/ssh/sshd_config"

check "MaxAuthTries set to 3" \
  "grep -q 'MaxAuthTries 3' /etc/ssh/sshd_config"

check "Idle timeout configured" \
  "grep -q 'ClientAliveInterval 300' /etc/ssh/sshd_config"

check "devuser exists" \
  "id devuser"

check "devuser is in sudo group" \
  "id devuser | grep -q sudo"

check "SSH service is running" \
  "sudo service ssh status | grep -q running"

check "UFW is active" \
  "sudo ufw status | grep -q 'Status: active'"

check "UFW allows port 222" \
  "sudo ufw status | grep -q '222/tcp'"

check "No empty passwords exist" \
  "! sudo awk -F: '(\$2 == \"\") {print \$1}' /etc/shadow | grep -q ."

echo ""
echo "=============================="
echo -e " Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo "=============================="
echo ""
