#!/bin/bash
# STEP 2 — Start MoveIt + RViz + Servo for the UR3e sim.
# Run AFTER sim_ur3e_servo.sh is fully up (controllers active).

source /opt/ros/humble/setup.bash
[ -f "$HOME/ros2_ws/install/setup.bash" ] && source "$HOME/ros2_ws/install/setup.bash"

# MoveIt + RViz
ros2 launch ur_moveit_config ur_moveit.launch.py \
    ur_type:=ur3e \
    launch_rviz:=true &

# Wait for controller manager to be ready before switching controllers
until ros2 service list 2>/dev/null | grep -q "/controller_manager/switch_controller"; do sleep 2; done

# Switch to forward_position_controller (required by MoveIt Servo)
ros2 control switch_controllers \
    --activate forward_position_controller \
    --deactivate scaled_joint_trajectory_controller \
    --strict --spin-time 30

# MoveIt Servo node
ros2 run moveit_servo servo_node --ros-args \
    --params-file "$(ros2 pkg prefix ur_moveit_config)/share/ur_moveit_config/config/ur_servo.yaml"

