#!/bin/bash
set -uo pipefail

REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/aws-audit-report.txt"
mkdir -p "$REPORT_DIR"

# Exit codes: 0 = HEALTHY, 1 = WARN, 2 = FAIL
EXIT_HEALTHY=0
EXIT_WARN=1
EXIT_FAIL=2

check_s3_public_access_block() {
  for bucket in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
    result=$(aws s3api get-public-access-block --bucket "$bucket" --output json 2>&1)
    if echo "$result" | grep -q '"BlockPublicAcls": true' && \
       echo "$result" | grep -q '"IgnorePublicAcls": true' && \
       echo "$result" | grep -q '"BlockPublicPolicy": true' && \
       echo "$result" | grep -q '"RestrictPublicBuckets": true'; then
      echo "PASS - $bucket - all public access block settings enabled"
    else
      echo "WARN - $bucket - public access block not fully enabled"
      echo "  Evidence: $result"
    fi
  done
  return $EXIT_HEALTHY
}

check_ssh_open_to_world() {
  local open_sgs
    open_sgs=$(aws ec2 describe-security-groups \
    --query "SecurityGroups[?IpPermissions[?FromPort==\`22\` && ToPort==\`22\` && contains(IpRanges[].CidrIp, '0.0.0.0/0')]].[GroupId,GroupName]" \
    --output text)
  if [ -z "$open_sgs" ]; then
    echo "PASS - no security groups expose port 22 to 0.0.0.0/0"
    return $EXIT_HEALTHY
  else
    echo "FAIL - the following security groups expose port 22 to 0.0.0.0/0:"
    echo "$open_sgs"
    return $EXIT_FAIL
  fi
}

check_mysql_open_to_world() {
  local open_sgs
    open_sgs=$(aws ec2 describe-security-groups \
    --query "SecurityGroups[?IpPermissions[?FromPort==\`3306\` && ToPort==\`3306\` && contains(IpRanges[].CidrIp, '0.0.0.0/0')]].[GroupId,GroupName]" \
    --output text)
  if [ -z "$open_sgs" ]; then
    echo "PASS - no security groups expose port 3306 to 0.0.0.0/0"
    return $EXIT_HEALTHY
  else
    echo "FAIL - the following security groups expose port 3306 to 0.0.0.0/0:"
    echo "$open_sgs"
    return $EXIT_FAIL
  fi
}

check_rds_publicly_accessible() {
  local rows exit_code=$EXIT_HEALTHY
  rows=$(aws rds describe-db-instances \
    --query 'DBInstances[].[DBInstanceIdentifier,PubliclyAccessible]' --output text)
  while read -r id public; do
    [ -z "$id" ] && continue
    if [ "$public" == "False" ]; then
      echo "PASS - $id - not publicly accessible"
    else
      echo "FAIL - $id - publicly accessible"
      exit_code=$EXIT_FAIL
    fi
  done <<< "$rows"
  return $exit_code
}

check_ebs_encryption() {
  local rows exit_code=$EXIT_HEALTHY
  rows=$(aws ec2 describe-volumes \
    --query 'Volumes[].[VolumeId,Encrypted]' --output text)
  while read -r id encrypted; do
    [ -z "$id" ] && continue
    if [ "$encrypted" == "True" ]; then
      echo "PASS - $id - encrypted"
    else
      echo "WARN - $id - not encrypted"
      [ $exit_code -lt $EXIT_WARN ] && exit_code=$EXIT_WARN
    fi
  done <<< "$rows"
  return $exit_code
}

# Array of check names mapped to their function names
checks=(
  "S3 Public Access Block Status:check_s3_public_access_block"
  "SSH Port 22 Open to 0.0.0.0/0:check_ssh_open_to_world"
  "MySQL Port 3306 Open to 0.0.0.0/0:check_mysql_open_to_world"
  "RDS PubliclyAccessible Status:check_rds_publicly_accessible"
  "EBS Volume Encryption Status:check_ebs_encryption"
)

echo "AWS Security & Cost Audit - Maida Sehar - $(date)" > "$REPORT_FILE"
echo "======================================" >> "$REPORT_FILE"

overall_exit=$EXIT_HEALTHY
i=1
for entry in "${checks[@]}"; do
  name="${entry%%:*}"
  func="${entry##*:}"
  echo "" >> "$REPORT_FILE"
  echo "[$i] $name" >> "$REPORT_FILE"
  output=$("$func")
  code=$?
  echo "$output" >> "$REPORT_FILE"
  [ $code -gt $overall_exit ] && overall_exit=$code
  i=$((i+1))
done

echo "" >> "$REPORT_FILE"echo "Audit complete. Report written to $REPORT_FILE" >> "$REPORT_FILE"
cat "$REPORT_FILE"

exit $overall_exit
