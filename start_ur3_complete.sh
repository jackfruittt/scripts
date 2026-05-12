#!/bin/bash
# Start UR3 driver and MoveIt together with RViz

set -e

# Default values
ROBOT_IP=${ROBOT_IP:-"192.168.1.102"}
USE_FAKE_HARDWARE=${USE_FAKE_HARDWARE:-"true"}
LAUNCH_RVIZ=${LAUNCH_RVIZ:-"true"}

echo "Starting UR3 Complete System..."
echo "Robot IP: $ROBOT_IP"
echo "Use fake hardware: $USE_FAKE_HARDWARE"
echo "Launch RViz: $LAUNCH_RVIZ"

# Source ROS2 Humble
if [ -f "/opt/ros/humble/setup.bash" ]; then
    source /opt/ros/humble/setup.bash
else
    echo "Error: ROS2 Humble not found at /opt/ros/humble/setup.bash"
    exit 1
fi

# Source workspace if it exists
if [ -f "$HOME/ros2_ws/install/setup.bash" ]; then
    source ~/ros2_ws/install/setup.bash
fi

# Launch UR3 driver and MoveIt together
if [ "$USE_FAKE_HARDWARE" = "true" ]; then
    echo "Launching UR3 with MoveIt (simulation mode)..."
    ros2 launch ur_robot_driver ur_control.launch.py \
        ur_type:=ur3 \
        robot_ip:=$ROBOT_IP \
        use_fake_hardware:=true \
        launch_rviz:=false &
    
    # Wait for driver to initialize
    sleep 5
    
    # Launch MoveIt with RViz
    ros2 launch ur_moveit_config ur_moveit.launch.py \
        ur_type:=ur3 \
        use_fake_hardware:=true \
        launch_rviz:=$LAUNCH_RVIZ
else
    echo "Launching UR3 with MoveIt (real hardware)..."
    ros2 launch ur_robot_driver ur_control.launch.py \
        ur_type:=ur3 \
        robot_ip:=$ROBOT_IP \
        use_fake_hardware:=false \
        launch_rviz:=false &
    
    # Wait for driver to initialize
    sleep 5
    
    # Launch MoveIt with RViz
    ros2 launch ur_moveit_config ur_moveit.launch.py \
        ur_type:=ur3 \
        use_fake_hardware:=false \
        launch_rviz:=$LAUNCH_RVIZ
fi
