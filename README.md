## LifeBand: Smart Wearable IoT Device

### Project Overview

LifeBand is an advanced IoT-based wearable device meticulously engineered for personal safety and continuous health monitoring. Its core purpose is to provide peace of mind to caregivers by ensuring the well-being of individuals, particularly the elderly. The device integrates a suite of sensors and communication modules to automate critical safety functions, including fall detection, real-time vital sign tracking, and immediate emergency alerts. The system's mobile application serves as a comprehensive dashboard, allowing caregivers to remotely monitor the user's health metrics, view their live location on a map, manage emergency contacts, and configure the device wirelessly.

---

### Features

* **Fall Detection**: The device utilizes a high-precision Inertial Measurement Unit (IMU) to continuously monitor the user's motion and orientation. Sophisticated algorithms analyze this data to accurately identify a sudden, abnormal change in motion characteristic of a fall, minimizing false alarms.
* **Heart Rate Monitoring**: The integrated photoplethysmography (PPG) sensor provides continuous, non-invasive heart rate data. This vital information is transmitted in real-time to the mobile application, allowing caregivers to track the user's cardiac health and identify potential irregularities.
* **Live GPS Tracking**: The device is equipped with a high-accuracy GPS module that provides real-time location data. This information is displayed on a live map within the mobile app, enabling caregivers to track the user's movements and quickly locate them in an emergency.
* **Emergency SOS**: In a non-fall emergency, the user can manually trigger an SOS alert via a dedicated button. This action instantly sends a distress signal to pre-configured emergency contacts, along with the user's last known location.
* **Notification System**: The system provides a multi-layered alert mechanism. Upon detection of a fall or activation of the SOS, it can play a sound on the device itself and send a push notification to the caregiver's mobile phone, ensuring immediate awareness.
* **Bluetooth Configuration**: To simplify initial setup, the device uses a low-power Bluetooth Low Energy (BLE) connection. The mobile application can securely transfer the home Wi-Fi credentials (SSID and password) to the device, which then allows it to connect to the internet and communicate with the Firebase Realtime Database.
* **Remote Monitoring**: All sensor data, including heart rate, fall detection status, and GPS location, is streamed to a secure Firebase Realtime Database. The mobile application retrieves this data in real-time, providing caregivers with an up-to-the-minute overview of the user's status from anywhere with an internet connection.

---

### Components

The hardware components for the LifeBand are carefully selected for performance, power efficiency, and size, allowing for a compact and durable design.

* **ESP32-WROOM-32**: This powerful system-on-a-chip (SoC) serves as the brain of the device. It combines Wi-Fi and Bluetooth capabilities with a dual-core processor, making it ideal for processing sensor data and handling wireless communication simultaneously.
* **SIM868**: A crucial component for communication outside of a Wi-Fi network. This module provides both Global System for Mobile (GSM) cellular connectivity for sending SMS alerts and Global Positioning System (GPS) functionality.
* **MPU6050**: An essential sensor for safety monitoring. This 6-axis IMU combines a 3-axis accelerometer and a 3-axis gyroscope to provide precise data on acceleration and angular velocity, which is fundamental for detecting the unique motion signature of a fall.
* **MAX30102**: A highly sensitive optical sensor used for heart rate and SpO2 (blood oxygen saturation) monitoring. It works by measuring light absorption changes in the user's blood, providing accurate vital sign readings.
* **u-blox NEO-M8N**: While the SIM868 has an integrated GPS, a dedicated u-blox module is included for enhanced positioning accuracy and faster satellite lock times, which is critical for providing reliable location data.
* **3.7V 1000 mAh Li-Po (protected)**: A robust, protected Lithium Polymer battery that provides a significant power source for the device, ensuring it can operate for extended periods between charges.
* **MCP73871**: A dedicated charge management controller designed for single-cell Li-Po batteries. It safely regulates the charging process, preventing overcharging and extending the battery's lifespan.
* **TPS62840**: A step-down converter that efficiently regulates the voltage supplied to the ESP32 and other components, optimizing power consumption and extending the device's battery life.

---

### Wires & Pins

The selection of wires and connectors is optimized for assembly, durability, and a compact form factor.

* **Jumper Wires**: A variety of male-to-female, male-to-male, and female-to-female jumper wires are used for prototyping and connecting components on a breadboard or between breakout modules.
* **Flexible silicone-coated wire (28–30 AWG)**: This type of wire is preferred for the final assembly due to its high flexibility and durability, making it perfect for connecting components within a small enclosure without risk of breaking.
* **Ribbon cable**: Used to connect components that require multiple parallel data lines, providing a neat and organized solution for wiring.
* **Pin headers**: Both straight and right-angle pin headers are used for secure, solderable connections to PCBs and for providing a reliable interface for detachable wires.
* **JST-PH 2.0 connectors**: These small, polarized connectors are used for secure connections, particularly for the battery, ensuring the power supply cannot be accidentally reversed.
* **Micro coaxial GPS antenna connector (u.FL)**: A tiny coaxial connector used to attach the external GPS antenna to the u-blox module, essential for receiving a strong satellite signal.
* **SMA pigtail cable**: An adapter cable that converts the small u.FL connector to a larger SMA connector, which is a standard interface for external antennas, providing flexibility in antenna selection.
