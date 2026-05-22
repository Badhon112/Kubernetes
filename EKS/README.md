## StateFull vs StateLess

- A _StateFull_ app is code + data, tightly coupled. Its behavior depends on internal memory or persistent data it holds or stores.
- A _stateless_ app is just code. it can be stopped, restarted, or rescheduled without user disruption

### What it takes to run a Database?

One primary node (formerly called the master) : handles all writes Multiple replicas (read-only) : provide redundancy and help with read scaling.
