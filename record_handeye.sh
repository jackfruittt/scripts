#!/bin/bash
# Record hand-eye calibration bag from Unity publishers.
# Usage:  ./record_handeye.sh <bag_name>
# Example: ./record_handeye.sh handeye_bag_01
#
# Topics recorded:
#   /unity/tool0_pose    - T_base_tool0 from RobotFKSolver (FLU)
#   /unity/apriltag_pose - T_cam_tag from Detection (FLU, gated on detection)
#
# Press Ctrl+C to stop recording.

BAG_NAME="${1:-handeye_bag}"

if [[ -d "$BAG_NAME" ]]; then
    echo "[record_handeye] '$BAG_NAME' already exists. Choose a different name or delete it first."
    exit 1
fi

echo "[record_handeye] Recording to '$BAG_NAME' ..."
echo "[record_handeye] Move the robot to 15-20 diverse poses, then Ctrl+C to stop."
echo ""

source /root/rs2_ws/install/setup.bash

ros2 bag record \
    /unity/tool0_pose \
    /unity/apriltag_pose \
    -o "$BAG_NAME"
