#!/bin/bash
# Run ROS2 TCP Endpoint server

set -e

ROS_IP=${ROS_IP:-"0.0.0.0"}
ROS_TCP_PORT=${ROS_TCP_PORT:-10000}

echo "Starting ROS2 TCP Endpoint..."
echo "ROS_IP: $ROS_IP"
echo "ROS_TCP_PORT: $ROS_TCP_PORT"

if [ -f "/opt/ros/humble/setup.bash" ]; then
    source /opt/ros/humble/setup.bash
else
    echo "Error: ROS2 Humble not found"
    exit 1
fi

if [ -f "$HOME/ros2_ws/install/setup.bash" ]; then
    source ~/ros2_ws/install/setup.bash
fi

# QoS overrides: realsense publishes IMU as BEST_EFFORT; endpoint must match.
# The original script had a missing \ after $ROS_TCP_PORT so --ros-args
# was never actually passed — that was the bug.
ros2 run ros_tcp_endpoint default_server_endpoint --ros-ip $ROS_IP --ros-port $ROS_TCP_PORT \
  --ros-args \
  -p "qos_overrides./camera/camera/gyro/sample.reliability:=best_effort" \
  -p "qos_overrides./camera/camera/accel/sample.reliability:=best_effort"
