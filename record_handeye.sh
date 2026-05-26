#!/bin/bash
# Record hand-eye calibration bag from Unity publishers.
# Each call captures one static robot pose for DURATION seconds.
# Bags are saved to ~/Software/calibration_camera/ on the host
# (mounted as /root/Software/calibration_camera/ inside the container).
#
# Usage:  ./record_handeye.sh [duration_seconds]
# Example: ./record_handeye.sh        # 5s default, auto-names handeye_bag_01, _02, ...
#          ./record_handeye.sh 8      # 8s capture
#
# Topics recorded:
#   /unity/tool0_pose    - T_base_tool0 from RobotFKSolver (FLU)
#   /unity/apriltag_pose - T_cam_tag from Detection (FLU, gated on detection)

DURATION="${1:-5}"
CONTAINER="r2_humble_dev"
HOST_OUT_DIR="$HOME/Software/calibration_camera"
CONTAINER_OUT_DIR="/root/Software/calibration_camera"

mkdir -p "$HOST_OUT_DIR"

# Auto-increment bag number
INDEX=1
while [[ -d "${HOST_OUT_DIR}/handeye_bag_$(printf '%02d' $INDEX)" ]]; do
    INDEX=$((INDEX + 1))
done
BAG_NAME="handeye_bag_$(printf '%02d' $INDEX)"
HOST_BAG_PATH="${HOST_OUT_DIR}/${BAG_NAME}"
CONTAINER_BAG_PATH="${CONTAINER_OUT_DIR}/${BAG_NAME}"

echo "[record_handeye] Pose ${INDEX}: recording '${BAG_NAME}' for ${DURATION}s ..."

docker exec "$CONTAINER" bash -c "
    source /opt/ros/humble/setup.bash
    timeout ${DURATION} ros2 bag record \
        /unity/tool0_pose \
        /unity/apriltag_pose \
        -o ${CONTAINER_BAG_PATH}
"

echo "[record_handeye] Done. Bag saved to ${HOST_BAG_PATH}"
