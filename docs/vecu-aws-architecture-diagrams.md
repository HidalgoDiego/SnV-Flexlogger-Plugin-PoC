```mermaid
flowchart TB
    subgraph AWS[AWS VPC / Control Plane]
        A1[Developer / Browser]
        A2[Amazon EKS]
        A3[Harness Control Loop]
        A4[Provisioning / Access]
    end

    subgraph CONN[Secure AWS Connection]
        C1[Control tunnel / VPC link]
    end

    subgraph HOST[On-Prem Bare-Metal Host]
        H1[Rig 1\nAndroid + vECU]
        H2[Rig 2\nAndroid + vECU]
        H3[Rig 3\nAndroid + vECU]
        H4[Host runtime services]
    end

    subgraph NET[Shared Vehicle Network]
        N1[L2 vehicle network]
        N2[Multicast + SOME/IP]
        N3[NATS / Signal Broker]
        N4[Peer vECU / ECU endpoints]
    end

    A1 --> A2
    A2 --> A3
    A3 --> A4
    A4 --> C1
    C1 --> H1
    C1 --> H2
    C1 --> H3
    C1 --> H4

    H1 --> N1
    H2 --> N1
    H3 --> N1
    H4 --> N1

    N1 --> N2
    N1 --> N3
    N2 --> N4
    N3 --> N4

    classDef aws fill:#153f63,stroke:#74d0ff,color:#eef8ff,stroke-width:1.5px;
    classDef conn fill:#3d2d4d,stroke:#d8a8ff,color:#f8f1ff,stroke-width:1.5px;
    classDef host fill:#1b463d,stroke:#6fe5c6,color:#ecfff9,stroke-width:1.5px;
    classDef net fill:#4a3b2f,stroke:#ffbf7a,color:#fff4e8,stroke-width:1.5px;

    class A1,A2,A3,A4 aws;
    class C1 conn;
    class H1,H2,H3,H4 host;
    class N1,N2,N3,N4 net;
```

```mermaid
flowchart LR
    subgraph AWS[AWS VPC / Control Plane]
        A1[Amazon EKS]
        A2[Control loop]
        A3[Lifecycle management]
    end

    subgraph LINK[Connection to Edge]
        L1[Secure control path]
        L2[Access / telemetry / provisioning]
    end

    subgraph HOST[Shared Bare-Metal Host]
        H1[rig-user-1]
        H2[rig-user-2]
        H3[rig-user-3]
        H4[rig-user-4]
    end

    subgraph NET[Vehicle Network Fabric]
        N1[Shared L2 segment]
        N2[Multicast]
        N3[NATS / discovery]
    end

    subgraph APP[Virtual ECU / Services]
        P1[Peer vECU]
        P2[Signal broker]
        P3[Vehicle apps]
    end

    A1 --> A2
    A2 --> A3
    A3 --> L1
    L1 --> L2
    L2 --> H1
    L2 --> H2
    L2 --> H3
    L2 --> H4

    H1 --> N1
    H2 --> N1
    H3 --> N1
    H4 --> N1

    N1 --> N2
    N1 --> N3
    N2 --> P1
    N3 --> P2
    P1 --> P3

    classDef aws fill:#153f63,stroke:#74d0ff,color:#eef8ff,stroke-width:1.5px;
    classDef link fill:#3d2d4d,stroke:#d8a8ff,color:#f8f1ff,stroke-width:1.5px;
    classDef host fill:#1b463d,stroke:#6fe5c6,color:#ecfff9,stroke-width:1.5px;
    classDef net fill:#4a3b2f,stroke:#ffbf7a,color:#fff4e8,stroke-width:1.5px;
    classDef app fill:#3d4858,stroke:#b7c9e4,color:#eef5ff,stroke-width:1.5px;

    class A1,A2,A3 aws;
    class L1,L2 link;
    class H1,H2,H3,H4 host;
    class N1,N2,N3 net;
    class P1,P2,P3 app;
```

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant AWS as AWS Control Plane
    participant Link as Secure Cloud Link
    participant Host as Bare-Metal Host
    participant Rig as Rig Instance
    participant Net as Shared Vehicle Network
    participant Broker as NATS / Broker

    Dev->>AWS: Start / access environment
    AWS->>Link: Provision and manage rig
    Link->>Host: Connect control path
    Host->>Rig: Launch Android + vECU stack
    Rig->>Net: Join shared L2 fabric
    Rig->>Broker: Register service / signal endpoint
    Dev->>Host: Access UI, logs, adb
    Rig-->>Net: Publish / subscribe traffic
    Net-->>Broker: Route vehicle messages
    AWS->>Host: Scale / tear down
```
