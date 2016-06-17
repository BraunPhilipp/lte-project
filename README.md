# LTE Project

## Indicators
**Rank Indicator (RI)**
- Rank Indicator 1 > eNB starts sending data in Tx diversity mode to UE
- Rank Indicator 2 > eNB starts sending downlink data in MIMO mode (Transmission Mode 3)
- Determines Precoding Matrix Indicator (PMI)

**Channel Quality Indicator (CQI)**
- Values > {0, ..., 15}
- 0 > Low Coding Rate & High Modulation (High Throughput)
- 15 > High Coding Rate (QAM) & Low Modulation (Low Throughput)

## Upcoming Tasks
- Plot users on cell edges in different color
- Fix Modulation based on CQI
- Moving User Entities (Random Walk)
- Connect Scheduling of different Basestations (Muting)
- Determine Backhaul and Distance to Central Unit
- Beamforming ?
