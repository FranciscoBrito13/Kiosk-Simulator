# Kiosk-Simulator
The Kiosk Simulator is a university project built on a simple level, showcasing different implementations of a virtual product purchase experience. Divided into three parts, this repository provides code and resources for each implementation, allowing users to explore and understand various approaches to building virtual kiosks.

Part 1: Bash Implementation
In the first part, a Bash implementation provides a console-based kiosk experience. Users can interact with the kiosk by navigating through product options and selecting their choices, resulting in changes to the corresponding database file. This implementation serves as an introductory example, emphasizing the fundamentals of a virtual kiosk system.

Part 2: C Implementation with Client-Server Architecture
The second part focuses on a client-server architecture implemented in C. The project leverages several key concepts, including process creation and concurrency using fork and wait, inter-process communication using signals (kill, signal, and alarm), sequential and direct file manipulation (so_fgets, fprintf, fread, fwrite, fseek), user interaction (printf, so_gets, so_geti), and communication using Named Pipes or FIFOs (S_ISFIFO, stat). Dedicated servers are created to handle individual clients, ensuring efficient and concurrent virtual kiosk experiences.

Part 3: C Implementation with Message Queue, Semaphores, Shared Memory, and IPC
The third part utilizes advanced concepts such as shared memory IPC (shmget, shmat, shmdt), process concurrency using IPC semaphores (semget, semctl, semop), and communication using IPC message queues (msgget, msgsnd, msgrcv). This implementation further enhances the scalability, efficiency, and inter-process communication in the kiosk simulation. Users can interact with the kiosk, and communication between clients and servers is managed using shared memory, semaphores, and message queues. This implementation demonstrates the integration of advanced IPC mechanisms into a virtual kiosk system.

This university project serves as an educational exercise, providing students with hands-on experience in designing and implementing virtual kiosk simulations. Through these three parts, we can explore different aspects of the project, including user interaction, networking, system-level mechanisms, inter-process communication techniques, and IPC concepts. It offers a practical introduction to the concepts and technologies involved in creating virtual kiosk systems.
