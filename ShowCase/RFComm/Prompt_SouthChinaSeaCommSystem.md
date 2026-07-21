# Project Prompt: UAS Avionics, Autonomy, and Datalink Analysis[cite: 3]

## 1.0 Overview
Your team has been asked to assist in the development of requirements and some preliminary analysis for a UAS known as SMEM (Strategically-Managed Exploration Module) for future Intelligence, Surveillance, and Reconnaissance (ISR) system deployment from a Littoral Combat Ship 2 (LCS-2) class ship in waters surrounding Southeast Asia[cite: 3].

The areas of analysis for this study will be the following:
* **Link budget** based upon system requirements and known receiver characteristics[cite: 3].

---

## 2.0 Mission
The SMEM system shall takeoff from an LCS-2 class ship to perform ISR data collection of areas of interest (land and sea) with an effective operating radius of 600 nautical miles (NM)[cite: 3]. The aircraft will fly at a mission altitude of 10,000 to 25,000 ft. mean sea level (MSL)[cite: 3].

### SMEM Conceptual Rendering & Mission Profile
The system mission profile is as follows[cite: 3]:
* **Launch**: deployment from LCS-2 ship via direct RF LOS command and control[cite: 3].
* Climb-out to a cruising altitude between 10,000 and 25,000 ft[cite: 3].
* Transit to ISR mission site[cite: 3].
* **Mission Loiter (ISR)**[cite: 3].
* Transit to LCS-2 ship[cite: 3].
* Descent/approach[cite: 3].
* **Recovery** on LCS-2 ship utilizing a combination of arresting cable and net (precision approach)[cite: 3].

During the mission, RF LOS communication will be maintained during takeoff, climb-out, descent/approach, and recovery[cite: 3]. Additionally, RF LOS communication will be utilized as primary for the effective range of the RF LOS datalink when within range of a receiver (i.e., launch ship or another suitably equipped LCS-2 ship)[cite: 3]. RF BLOS communication will be maintained as the redundant command-and-control link for transit to/from the ISR mission area and the duration of the ISR loiter, during which the system can be operated under limited pilot control (ad hoc change of flight path) or under automation[cite: 3]. 

The system's recovery will be automated given the need for a precision approach that also accounts for current winds aloft[cite: 3]. Under extreme conditions, a pilot can manually control the UAS for launch/recovery via the RF LOS datalink[cite: 3].

### Security and Redundancy
* **Alternative Landing Site**: An alternative landing site (if available) will be sent to the SMEM at least once every 10 minutes whenever a positive command-and-control link is established[cite: 3]. An alternative landing site will have an RF LOS datalink and control station capable of system recovery so long as the RF LOS datalink is functional[cite: 3].
* **Flight Termination**: If the system cannot reach a suitable landing site (primary or alternative) due to a system failure, a flight termination system will be triggered to destroy the vehicle with extreme prejudice[cite: 3].
* **Avionics Redundancy**: To reduce risk, a triplex avionics architecture is required for all major avionics systems (excluding communication, which fall under their own subsystem architecture)[cite: 3].

---

## 3.0 Development of Requirements and Additional Analysis
Requirements and additional analysis must be drawn from the system/mission description above as well as system needs/expectations as described in the textbook[cite: 3]. 

Please realize that this will be a preliminary requirements document with additional details regarding the airframe, flight controls, propulsion, etc., being unknown at this time[cite: 3]. For example, requirements on the update rates for the sensors would likely be too detailed for this project[cite: 3].

### 3.1 Communication
* **Requirements from Mission**: Define all requirements from the mission requirement, and if necessary, additional requirements to fully describe the system requirements as a whole[cite: 3]. The link budget analysis below will provide some requirements for the system, including the antenna gains[cite: 3].

#### 3.1.1 Link Budget Analysis
You have been tasked to generate a link budget spreadsheet for the L-Band RF LOS datalink between the control station and the UAS[cite: 3]. Below are known data elements[cite: 3]. The current unknown is the minimum antenna gain necessary to achieve a net signal margin of at least 31.5 dB to account for various unaccounted losses (such as multi-path) with a range of 10 nautical miles[cite: 3]. Your job shall be to derive this gain through a link budget analysis spreadsheet[cite: 3].

> **Note**: Since the UAS radio and ground radio have symmetric configurations (i.e., identical specifications) for both their transmitter power and required SNR for receiver, you will only need to model the analysis one way[cite: 3]. Therefore, you only need to model the downlink path to complete your analysis[cite: 3]. The BLOS datalink will not need to be analyzed for this project[cite: 3].

#### 3.3.1.1 Link Budget Data Provided
The datalink will be based off the DO-362 standard for an L-Band datalink operating at 1060.5 MHz[cite: 3]. The analysis assumes the worst-case demand on the link, so a modulation rate of 138 kbits/s across a 120 kHz bandwidth is required[cite: 3]. Both transmitter and receiver will have a transmit power of 15 dBm and a minimum SNR per bit ($E_b/N_0$) of 3.5 dB[cite: 3].

* **General Parameters**:
  * Range = 10 nautical miles[cite: 3]
  * Modulation Rate = 138 kbits/s across 120 kHz[cite: 3]
* **Signal Properties**:
  * Frequency ($f$) = 1060.5 MHz[cite: 3]
  * Modulation Data Rate ($R_{\text{Data}}$) = 138,000 bit/sec[cite: 3]
  * Ideal Receiver Bandwidth ($B$) = 120 kHz[cite: 3]
  * No spread spectrum use[cite: 3]
* **UAS Communication Hardware**:
  * Tx Power = 15 dBm[cite: 3]
  * Antenna Type = Omnidirectional, vertically polarized[cite: 3]
  * Line Loss = 1 dB[cite: 3]
  * Pointing Loss = 0 dB[cite: 3]
  * Gain = TBD through your analysis[cite: 3]
  * Receiver $E_b/N_0$ threshold = 3.5 dB[cite: 3]
  * Receiver Noise Figure = 4 dB[cite: 3]
  * Antenna Polarization Loss = 3 dB (assumed)[cite: 3]
  * Radome Loss = 1 dB[cite: 3]
* **Control Station Communication Hardware**:
  * Tx Power = 15 dBm[cite: 3]
  * Antenna Gain = 19 dBi[cite: 3]
  * Antenna Type = Dish antenna (directional), circularly polarized[cite: 3]
  * Line Loss = 1 dB[cite: 3]
  * Pointing Loss = 0 dB[cite: 3]
  * Receiver $E_b/N_0$ threshold = 3.5 dB[cite: 3]
  * Receiver Noise Figure = 4 dB[cite: 3]
  * Antenna Polarization Loss = 3 dB (assumed)[cite: 3]
  * No radome[cite: 3]
* **Atmospheric and Precipitation**:
  * Atmospheric Loss = 0.926 dB (est.)[cite: 3]
  * Precipitation Loss = 0.02 dB (est.)[cite: 3]
  * Target Signal Margin = 31.5 dB[cite: 3]

### 3.3.2 Link Budget Reporting Requirements
In your final report, present the full link budget with the final UAS antenna gain clearly labeled[cite: 3]. In your report, please state the required antenna gain[cite: 3]. If any further assumptions or external referencing is required, please state them as well[cite: 3].