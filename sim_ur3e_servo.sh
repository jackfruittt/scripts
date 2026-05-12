#!/bin/bash
# STEP 1 — Start UR3e driver with mock hardware.
# Run this first, then run sim_ur3e_moveit.sh in a second terminal.

source /opt/ros/humble/setup.bash
[ -f "$HOME/ros2_ws/install/setup.bash" ] && source "$HOME/ros2_ws/install/setup.bash"

ros2 launch ur_robot_driver ur_control.launch.py \
    ur_type:=ur3e \
    robot_ip:=192.168.0.194 \
    use_mock_hardware:=true \
    launch_rviz:=false


wait
