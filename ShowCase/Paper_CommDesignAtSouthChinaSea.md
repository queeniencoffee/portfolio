

--- PAGE 1 ---

1 
 
 
 
 
 
 
 
High-level Conceptual Design of RF Communication System at South China Sea 
 
Sally Law 
Embry-Riddle Aeronautical University 
July 5, 2026 
  

--- PAGE 2 ---

2 
 
Table of Contents 
1.0 Introduction to the use of RF communication system in South China Sea .......................... 4 
1.1 UA V Operational Frequency Validation ............................................................................... 5 
1.2 FCC/ITU Frequency Zoning Validation at South China Sea ............................................ 5 
1.3 Frequency Spectrum Sovereignty ..................................................................................... 6 
1.4 Tactical Conflict and Spectral Risk ................................................................................... 7 
2.0 Mission Profile for Communication System & Navigation Plan.......................................... 8 
3.0 Introduction to UA V Line-of-Sight (LOS) ............................................................................ 9 
3.1 UA V Navigation Path Design & Fresnel Zone clearance validation ................................ 9 
3.2 RF LOS Communication Design (Primary Communication) ..........................................11 
3.3 UA V Beyond Line-of-Sight (BLOS) Design (Redundant Communication) ...................... 12 
4.0 Link Budget Design (RF LOS Communication) ................................................................ 12 
4.1 Signal Link Margin ............................................................................................................. 12 
4.2 Effective Noise Power (𝑁0) ................................................................................................ 14 
4.3 Link Budget Losses............................................................................................................. 15 
4.3.1 Free Space Path Loss (FSPL) ...................................................................................... 16 
4.3.2 Atmospheric Absorption Loss ...................................................................................... 16 
4.3.3 Precipitation Losses ..................................................................................................... 17 
4.3.4 Total RF Propagation Loss ........................................................................................... 17 
4.4 Effective Carrier Power ...................................................................................................... 17 

--- PAGE 3 ---

3 
 
4.5 Equivalent Isotropic Radiated Power (EIRP) ..................................................................... 18 
4.6 Required Antenna Gain Adjustment Table .......................................................................... 20 
4.7 Minimum requirements for UA V Communication System (Link Budget) ......................... 21 
4.8 Link Budget Requirements Allocation (RF LOS) .............................................................. 23 
4.9 Link Budget Prediction based on Hardware selection (RF LOS) ....................................... 24 
4.10 Link Budget Prediction results.......................................................................................... 24 
5.0 Post-Link Budget Simulation, Analysis and Specification Updates ................................... 26 
5.1 Post Update: UA V RF Coverage Analysis & RF LOS Re-validation................................. 26 
6.0 Requirements Refinement & Final Requirements Specification ............................................ 29 
7.0 Final Design Specification ...................................................................................................... 32 
7.1 Final System Parameters ..................................................................................................... 32 
7.2 Final Link Budget Summary ............................................................................................... 33 
7.3 Hardware Selection Summary ............................................................................................ 34 
7.3.1 Airborne Transmitter Equipment ................................................................................. 34 
7.3.2 LCS-2 Ground Station Equipment ............................................................................... 35 
7.4 Design Verification Summary ............................................................................................. 35 
6.0 Conclusion .............................................................................................................................. 36 
References ..................................................................................................................................... 37 
 

--- PAGE 4 ---

4 
 
1.0 Introduction to the use of RF communication system in South China Sea 
As one of the world's most highly contested waterways, the South China Sea has become 
a continuous arena for intensive Electronic Warfare (EW), where regional state actors utilize 
"salami-slicing" and "cabbage tactics" to assert dominance entirely within the electromagnetic 
spectrum rather than through kinetic conflict. Consequently, the design of the UA V RF 
communication system must account for RF interference and tactical datalink interception, as 
discussed in the contingency plan. To successfully establish a robust communication link in this 
hostile theater, the baseline link budget calculation must withstand environmental degradation to 
guarantee a sufficient fade margin for survival. As the South China Sea functions as a contested 
grey zone where standard ITU databases do not always accurately reflect reality, the design of 
the UA V communication system must heavily rely on Open-Source Intelligence (OSINT) and 
geopolitical risk monitoring is mandatory prior to deployment. With the intended UA V L-band 
radio wave operating at 1060.5 MHz, a frequency highly sensitive to the tropical maritime 
boundary layer of the SCS, the link budget must dynamically account for the following 
constraints: 
 Rain & Moisture Absorption: Heavy tropical downpours and high absolute humidity 
cause localized signal attenuation and hydrometeor scattering. 
 Ionospheric Turbulence: Solar activity and ionospheric scintillation can induce rapid 
phase and amplitude fluctuations, degrading signal coherence. 
Note: While additional environmental losses can be factored in, the professor has indicated that 
only these two specific environmental losses will be required for this class project.  

--- PAGE 5 ---

5 
 
1.1 UA V Operational Frequency Validation 
Operational frequency validation is critical to bridge the gap between theoretical 
regulatory compliance and the hostile electromagnetic realities of the South China Sea. This 
process ensures that while the UA V’s 1060.5 MHz operating frequency aligns with international 
framework allocations, the system design actively accounts for de facto electronic warfare, 
contested spectrum sovereignty, and severe out-of-band interference risks near military air-
defense channels. 
1.2 FCC/ITU Frequency Zoning Validation at South China Sea 
To initiate the operational frequency validation for the target 1060.5 MHz link, the target 
frequency of 1060.5 MHz was cross-referenced against the International Telecommunication 
Union (ITU) framework for region 3 to establish a baseline of regulatory legitimacy. The ITU 
frequency allocation matrix confirms that the band surrounding 1060.5 MHz is strictly reserved 
for air-to-ground communications, aligning precisely with its primary international designation 
for Aeronautical Radionavigation Service (ARNS). This preliminary regulatory alignment 
ensures a theoretically low-risk civilian interference profile, completely isolated from standard 
commercial networks. 
Figure 1: ITU Frequency Zoning region 
 


--- PAGE 6 ---

6 
 
Table 1: ITU Frequency Allocation Table for Frequency between 894-1400 MHz 
Table of Frequency Allocations 894-1400 MHz (UHF) Page 31 
International Table United States Table 
Region 1 Table Region 2 Table Region 3 Table Federal Table Non-Federal Table FCC Rule Part(s) 
960-1164 
Aeronautical Mobile (R) 5.327A 
Aeronautical Radionavigation 5.328 
5.328AA 
960-1164 
Aeronautical Mobile (R) 5.327A 
Aeronautical Radionavigation 5.328 
5.328AA US78 US224 
Aviation (87) 
 
Table 2: Footnote from ITU specifying the use for frequency range at 1060.5 MHz 
 
1.3 Frequency Spectrum Sovereignty 
While regulatory compliance mandates cross-referencing spectrum allocations with ITU 
Region 3 guidelines, regulatory validation alone is insufficient for real-world operations within 
the South China Sea. Due to contested sovereignty claims driven by the Nine-Dash Line, 
regional state actors explicitly reject international maritime boundaries and legal frequency 
zoning across roughly 90% of the theater. Consequently, physical spectrum usage is governed by 
forward-deployed, de facto military enforcement rather than de jure international law. Because 
the South China Sea functions as a contested grey zone where standard ITU databases do not 
accurately reflect reality, transitioning from passive regulatory compliance to active Open-
Source Intelligence (OSINT) and geopolitical risk monitoring is mandatory prior to operation. 
(i) 5.327A The use of the frequency band 960-1164 MHz by the aeronautical mobile (R) 
service is limited to system that operate in accordance with recognized international 
aeronautical standards. Such use shall be in accordance with Resolution 417 (Rev.WRC-15) 
(328) 5.328 The use of the band 960-1215 MHz by the aeronautical radionavigation service is 
reserved on a worldwide basis for the operation and development of airborne electronic aids 
to air navigation and any directly associated ground-based facilities.  

--- PAGE 7 ---

7 
 
1.4 Tactical Conflict and Spectral Risk 
Operating a custom UA V platform at 1060.5 MHz introduces a tactical risk due to its 
extreme proximity to the core frequencies of military situational awareness at 1030 MHz 
(surface interrogators) and 1090 MHz (airborne transponders). In the highly volatile South China 
Sea theater, major military actors, including the PLAN, the US Navy, and regional coastal forces, 
depend entirely on these adjacent channels for mission-critical Identification Friend or Foe (IFF) 
and Secondary Surveillance Radar (SSR) systems. Deploying a high-power UA V transmitter in 
this narrow window presents an acute danger of out-of-band emissions bleeding directly into 
these strict guard bands. Such spectral encroachment could inadvertently degrade, blind, or 
disrupt active military air-defense and collision-avoidance tracking, risking catastrophic 
misidentification or an unintended kinetic escalation in a heavily contested grey zone. Thus, the 
UA V communication system's operating band must be rigorously filtered to enforce strict 
spectral containment, preventing out-of-band emissions from bleeding into adjacent channels and 
causing destructive inter-channel interference (ICI). 
  

--- PAGE 8 ---

8 
 
2.0 Mission Profile for Communication System & Navigation Plan 
The SMEM flight profile utilizes Line-of-Sight (LOS) communications as the primary 
link during launch, climb-out, descent, and recovery, while also serving as an active redundant 
backup whenever the aircraft is within operational physical range of a suitably equipped ship. 
For long-range operations, Beyond Line-of-Sight (BLOS) communication serves as the primary 
command-and-control link throughout the transit ingress, mission loiter, and transit egress 
phases. Under this dual-link framework, the system switches to BLOS for mission execution 
while reverting to automated or pilot-controlled LOS links during critical launch and shipboard 
recovery operations. 
Since the launch platform is an LCS-2 ship has a uniquely wide trimaran flight deck 
rather than a conventional longitudinal runway, a VTOL or helicopter configuration was selected 
and reflected in the Navigation Plan (NavPlan). 
Figure 2: UAV Operation Mission Profile
 


--- PAGE 9 ---

9 
 
3.0 Introduction to UA V Line-of-Sight (LOS) 
To ensure the UA V can maintain continuous line-of-sight during operation, both the 
geometric Line-of-Sight (LOS) path and the L-Band radio frequency (RF LOS) link were 
validated using MATLAB terrain datasets to confirm zero environmental or signal obstructions. 
The following analysis successfully validated requirements [UA V-2] and [UA V-3], serving as the 
formal technical verification artifacts required to sell off the RF communication system design. 
3.1 UA V Navigation Path Design & Fresnel Zone clearance validation 
The 10 NM waypoint profile was designed using MATLAB and Earthstar Geographics 
terrain datasets, confirming zero physical line-of-sight (LOS) obstructions between the Littoral 
Combat Ship and the UA V during critical near-ship phases. Furthermore, geometric analysis 
verifies complete first Fresnel Zone clearance. To validate Fresnel Zone clearance between the 
two offshore points, calculate the first Fresnel Zone radius at the midpoint of the link based on 
your operating frequency, and ensure the line-of-sight path clears the ocean surface by at least 
60% of that radius plus an allowance for earth curvature and atmospheric refraction. With the 
UA V cruising at 24,000 ft, the maximum 28.3-meter Fresnel radius remains thousands of feet 
above the sea surface, eliminating any risk of multipath encroachment or diffraction losses. 
Figure 3: UAV flight path route map (Zoom In) 
 


--- PAGE 10 ---

10 
 
Figure 4: UAV flight path route map (Zoom out) 
 
Table 3: UAV VTOL Navigation Flight Plan (NavPlan) 
WayPT Type / Phase Latitude Longitude Altitude 
(MSL) 
Distance 
from Ship 
Description 
WP-1A Launch / Origin 21°00'00" N 118°00'00" E Sea Level  
(0 ft) 0 NM 
deployment from LCS-
2 ship via direct RF 
LOS command and 
control (C2); BLOS is 
also available 
WP-1B Top of Vertical 
Climb (TOVC) 21°00'00" N 118°00'00" E 24,000 ft 0 NM  
(Over Ship) 
Climb-out to a cruising 
altitude at 24000 ft; 
maintain LOS C2 
control; BLOS served 
as redundant 
WP-2 Loiter Station 
(AOI) 20°50'00" N 118°00'00" E 24,000 ft 10.0 NM 
South 
Transit to ISR mission 
site (Entering Area of 
Interest AOI), station 
directly above Mission 
Loiter (ISR); mission 
collect; maintain LOS 
WP-3A 
Inbound Return / 
End of Forward 
Transit (EOFT) 
21°00'00" N 118°00'00" E 24,000 ft 0 NM (Over 
Ship) 
Transit to LCS-2 ship; 
maintain RF LOS 
WP-3B 
Vertical Descent 
/ End of Flight 
(EOF) 
21°00'00" N 118°00'00" E Sea Level  
(0 ft) 0 NM 
Descent/approach; 
Maintain direct RF 
LOS C2 Control; BLOS 
remains available 
 


--- PAGE 11 ---

11 
 
3.2 RF LOS Communication Design (Primary Communication)  
To establish and continuously maintain communication link, an L-Band RF Line-of-Sight 
link requires an unblocked, straight physical path between the ship's directional dish antenna and 
the UA V .  As the updated flight profile shows, the loiter station (WP-2) sits at 20°50'00'' N, 
118°00'00'' E, which is a downrange distance of exactly 10 Nautical Miles from the launch 
vessel. Because the designated operational height of the UA V is 24,000 ft, the physical curvature 
of the Earth does not drop the ship below the horizon relative to the aircraft; therefore, the entire 
flight profile physically stays well within the geometric line-of-sight footprint of the LCS-2 ship. 
Mathematically speaking, the horizon at this altitude extends past 130 Nautical Miles, meaning it 
is not a risk of an absolute loss of direct radio line-of-sight due to planetary curvature during this 
short-range mission. To strictly comply with the mandated mission profile requirements, a 
programmatic handover to the satellite-based Beyond Line-of-Sight (BLOS) architecture may be 
executed during the transit and loiter phases. 
Additionally, a pre-flight RF spectrum scan will be performed to analyze active 
frequency utilization within the operational area, allowing for the application of dynamic 
frequency notching if necessary to mitigate localized signal interference and preserve link 
integrity. 
The UA V RF operational profile validates design requirements against [UA V-8], [UA V-15] and 
[UA V-20]. 

--- PAGE 12 ---

12 
 
3.3 UA V Beyond Line-of-Sight (BLOS) Design (Redundant Communication) 
RF Beyond Line-of-Sight (BLOS) communication serves as the redundant command-
and-control link throughout the transit ingress, mission loiter, and transit egress phases. Under 
this dual-link framework, the system switches to BLOS for mission execution while reverting to 
automated or pilot-controlled LOS links during critical launch and shipboard recovery 
operations. Note: As stated in the customer specification (project prompt), analyzing the Beyond 
Line-of-Sight (BLOS) link budget is outside the scope of this project. 
4.0 Link Budget Design (RF LOS Communication) 
4.1 Signal Link Margin 
In radio frequency (RF) communication systems, the signal link margin represents the 
safety buffer between the actual received signal strength and the minimum power required by the 
receiver to maintain a reliable connection. This baseline ensures that the communication link 
remains robust against unexpected environmental losses, atmospheric attenuation, or changes 
due to environmental changes. The net signal margin is defined as: 
Net signal margin (dB) = Available SNR (dB) – Required SNR (dB) 
In Unmanned Aircraft System (UAS) communication link, the Required SNR is the 
minimum threshold of signal clarity that the receiver must capture to successfully demodulate 
and decode incoming data. If the actual signal quality remains above the Required SNR, data 
packets are processed reliably. Conversely, if the signal quality drops below this threshold, the 
system experiences packet loss, command dropouts, and video telemetry degradation. The 

--- PAGE 13 ---

13 
 
Required SNR accounts for both digital modulation requirements and hardware bandwidth 
constraints, and is calculated as follows: 
𝑅𝑒𝑞𝑢𝑖𝑟𝑒𝑑 𝑆𝑁𝑅 (𝑑𝐵) =ா್
ேబ
+𝐷𝑎𝑡𝑎 𝑅𝑎𝑡𝑒 (𝑑𝐵𝐻𝑧)−𝐵𝑎𝑛𝑑𝑤𝑖𝑑𝑡ℎ(𝑑𝐵𝐻𝑧) (eq. 1) 
Converting the operational data rate and channel bandwidth into logarithmic terms yields: 
𝐷𝑎𝑡𝑎 𝑅𝑎𝑡𝑒 (𝑑𝐵𝐻𝑧)= 10𝑙𝑜𝑔ଵ଴(𝑅ௗ௔௧௔)= 10𝑙𝑜𝑔ଵ଴(138𝑘𝑏𝑝𝑠) = 51.40 𝑑𝐵𝐻𝑧 (2) 
𝐵𝑎𝑛𝑑𝑤𝑖𝑑𝑡ℎ(𝑑𝐵𝐻𝑧)= 10𝑙𝑜𝑔ଵ଴(𝐵)= 10𝑙𝑜𝑔ଵ଴(120𝑘𝑏𝑝𝑠) = 50.79𝑑 𝐵𝐻𝑧 (3) 
By substituting (2) and (3) into (eq. 1),  
𝑅𝑒𝑞𝑢𝑖𝑟𝑒𝑑 𝑆𝑁𝑅=𝐸௕
𝑁଴
+𝐷𝑎𝑡𝑎 𝑅𝑎𝑡𝑒 (𝑑𝐵𝐻𝑧)−𝐵𝑎𝑛𝑑𝑤𝑖𝑑𝑡ℎ(𝑑𝐵𝐻𝑧) 
𝑅𝑒𝑞𝑢𝑖𝑟𝑒𝑑 𝑆𝑁𝑅= 3.5 𝑑𝐵+ 51.40 𝑑𝐵𝐻𝑧− 50.79 𝑑𝐵𝐻𝑧 
𝑹𝒆𝒒𝒖𝒊𝒓𝒆𝒅 𝑺𝑵𝑹=𝟒.𝟏𝟏 𝒅𝑩 
Per the system requirements defined in [UA V-1], the UAS communication link must 
maintain a target Net Signal Margin of at least 31.5 dB to ensure stable link connectivity 
throughout the mission profile. To determine the minimum Available SNR needed to satisfy this 
requirement, the margin equation is rearranged as follows: 
Net signal margin (dB) = Available SNR (dB) – Required SNR (dB) 
31.5 dB = Available SNR (dB) – 4.11 dB 
Available SNR (dB) = a minimum of 35.61 dB 
Thus, to guarantee robust command-and-control capabilities, the UA V communications 
subsystem shall maintain an Available Signal-to-Noise Ratio (SNR) of at least 35.61 dB at the 

--- PAGE 14 ---

14 
 
receiver, ensuring the system satisfies the mandatory 31.5 dB link margin. For the analytical 
assessments detailed in subsequent sections, the Available SNR is defined as: 
Available SNR(dB) = Effective carrier power (Ceff)(dBm) - Effective noise power (N0)(dBm) 
Here’s the summary of the minimum SNR for UA V to establish link with a minimum of 31.5 
dBm link margin: 
Table 4: UAV Communication System SNR Summary 
    Operation Units Value 
Summary 
Available SNR   dB 35.61 
Required SNR   dB 4.11 
Net signal margin (link margin)   dB 31.50 
 
4.2 Effective Noise Power (𝑵𝟎) 
Effective Noise Power represents the total raw power of the background electrical static 
present within the receiver's active channel, combined with the internal noise introduced by the 
receiver's electronics. This value establishes the absolute noise floor of the communication 
system; the incoming target signal must arrive with sufficient power above this floor to be 
successfully detected and demodulated. The effective noise power scales the baseline thermal 
noise density relative to the system's operational bandwidth and hardware quality, calculated as: 
Effective Noise Power (dBm) = Thermal Noise Density (kT) (dBW/Hz) + Rx Bandwidth (10log10B) + Noise Figure (NF) (dB) 
Driven by thermodynamic principles, the thermal noise density (N0) is the baseline 
electrical static caused by the thermal agitation of electrons. Assuming a standard operational 
ambient temperature of 290 K, the baseline thermal noise density is expressed as: 

--- PAGE 15 ---

15 
 
Thermal Noise Density (N0) (dBW/Hz) = 10log10 (k) + 10log10(T) = -174 dBm/Hz 
Thermal Noise Density (N0) (dBW/Hz) = -174 dBm/Hz 
Given Ideal Receiver Bandwidth, B=120 kHz, 
Rx noise bandwidth (BW) (dBHz) = 10log10(B) = 50.79 dBHz 
The receiver hardware introduces an additional degradation factor, specified by a Noise Figure 
(NF) of 4dB.  
Noise Figure = 4 dB 
Consequently, the absolute receiver noise floor for this configuration is: 
Effective Noise Power = Thermal Noise Density (kT)+Rx Bandwidth (10log10B)+Noise Figure (NF) 
Effective Noise Power = -174 dBm/Hz – 50.79 dBHz – 4 dB 
Effective Noise Power (N0) = -119.21 dBm 
Here’s the summary effective noise power for this UA V mission: 
Table 5: UAV Communication System Effective Noise Power Summary 
    Operation Units Value 
Noise 
Thermal noise density, kT @ 290K - dBm/Hz -174.00 
Rx noise bandwidth, BW - dBHz 50.79 
Rx noise figure, NF - db 4.00 
Effective noise power - dBm -119.21 
4.3 Link Budget Losses 
To maintain reliable command-and-control operations in the challenging South China Sea 
environment, the link budget incorporates critical signal degradation factors and environmental 
margins to ensure system functionality under extreme conditions. 

--- PAGE 16 ---

16 
 
4.3.1 Free Space Path Loss (FSPL) 
Free Space Path Loss (FSPL) is the reduction in power density of an electromagnetic 
signal as it travels in a straight line through an unobstructed, ideal vacuum, completely free of 
obstacles, absorption, or reflections. To calculate FSPL, the standard equation is:  
𝐹𝑆𝑃𝐿(𝑑𝐵)= 20𝑙𝑜𝑔ଵ଴(𝑑)+ 20𝑙𝑜𝑔ଵ଴(𝑓)+ 20𝑙𝑜𝑔ଵ଴(4𝜋
𝑐 ) 
By assuming worst case scenario, where:  
Frequency (f) = 1060.5 MHz 
Horizontal Ground distance = 10 NM  
UA V altitude (h) (worst case) = 25000 ft = 25000 ft / (6076.12 ft/NM) = 4.115 NM 
True Slant Range (d) can be calculated by:  
 𝑑=ඥ(10𝑁𝑀)ଶ + (4.115𝑁𝑀)ଶ =10.814 NM (1.852km/NM) = 20.028 km 
Free Space Path Loss:  
𝐹𝑆𝑃𝐿(𝑑𝐵)= 20𝑙𝑜𝑔ଵ଴(20.028𝑘𝑚)+ 20𝑙𝑜𝑔ଵ଴(1060.5𝑀𝐻𝑧)+ 32.45 
 
FSPL (dB) = 118.31 dB 
 
4.3.2 Atmospheric Absorption Loss 
Atmospheric loss, or atmospheric attenuation, represents the reduction in electromagnetic 
signal power as it propagates through the Earth's atmosphere. This loss can be modeled using an 
empirical power-law formula. To account for these environmental variations across the SMEM 
mission profile, the following fixed atmospheric loss is integrated into the downward line-of-
sight link budget:  
Atmospheric Loss, 0.926 dB (est.) 

--- PAGE 17 ---

17 
 
4.3.3 Precipitation Losses 
Precipitation loss, or rain attenuation, describes the degradation of electromagnetic signal 
strength due to atmospheric moisture such as rain, snow, hail, or fog. These losses are calculated 
using the empirical framework defined in ITU-R P.838-3, Specific attenuation model for rain for 
use in prediction methods. To evaluate the environmental margins for this mission profile, the 
following estimated precipitation loss is factored into the line-of-sight link budget:  
Precipitation loss, 0.02 dB (est.) 
 
4.3.4 Total RF Propagation Loss 
Thus, the total propagation losses is: 
𝑳𝑳𝒐𝒔𝒔=𝑭𝑺𝑷𝑳(𝒅𝑩)+𝑳𝑨𝒕𝒎𝒐𝒔𝒑𝒉𝒆𝒓𝒊𝒄+𝑳𝑹𝒂𝒊𝒏= −𝟏𝟏𝟗.𝟐𝟔 𝒅𝑩 
 
Here’s the summary of the RF Link Loss for this UA V mission: 
Table 6: UAV Communication System RF Link Loss Summary 
 
4.4 Effective Carrier Power 
Effective Carrier Power (Ceff) is the total magnitude of signal power that successfully 
arrives at the receiver's demodulation after accounting for all cumulative gains and systemic 
losses along the transmission path. For a downlink transmission, the Effective Carrier Power 
arriving at the Ground Control Station (GCS) receiver is mathematically modeled as: 
Effective Carrier Power(Ceff)(dBm) = EIRP(dBm) + Total Propagation Loss(dB) + Total GRX (dBi) – Total LRX(dB)(eq. A) 
OperationUnits ValueFree space path loss + dB -118.31Atospheric absorption, L_P,Atm + dB -0.93Precipitation absorption, L_P, Precip + dB -0.02Total Propagaton LossdB -119.26Propagation

--- PAGE 18 ---

18 
 
From section 3.5.1, the link requires a minimum Available SNR of 35.61 dB to preserve the 
mandatory safety margin, and the relationship between signal quality, carrier power, and the 
receiver noise floor is defined as: 
Available SNR (dB) = Effective carrier power (dB) - Effective noise power (dBm),  
Therefore,  
Effective carrier power (min.)(dBm) = Available SNR (min.)(dB) - Effective noise power (dBm) 
Minimum Effective carrier power (dBm) = 35.61 dB + ( -119.21 dBm) 
Minimum Effective carrier power (Ceff)  = - 83.60 dBm (i) 
Here’s the summary of the minimum Effective Carrier Power requirement for UA V to establish 
link with a minimum of 31.5 dBm link margin: 
Table 7: UAV Communication System Effective Carrier Power Summary 
    Operation Units Value 
LCS-2 
Control 
Station 
(Receiver) 
Rx peak antenna gain, G_R + dBi 19.00 
Rx polarizaton loss, L_R, Polar + dB -3.00 
Rx pointing Loss, L_R,Point + dB 0.00 
Rx radome loss, L_R, Radome + dB 0.00 
Rx component line losses, L_R, Line + dB -1.00 
Spreading implemetation loss, L_R,Spread + dB 0.00 
Effective carrier power   dBm -83.60 
4.5 Equivalent Isotropic Radiated Power (EIRP) 
Equivalent Isotropically Radiated Power (EIRP) represents the total effective power 
radiated by an antenna in its direction of maximum gain, measured relative to a theoretical 
isotropic antenna that radiates power equally in all directions. EIRP accounts for transmitter 
power output, internal transmission line losses, and the intentional directive gain of the antenna. 

--- PAGE 19 ---

19 
 
From Section 5.3, the minimum required Effective Carrier Power (Ceff) arriving at the receiver is 
-83.60 dBm. To isolate the minimum required EIRP from the primary link budget equation, the 
system parameters are arranged as follows: 
𝐸𝐼𝑅𝑃(𝑑𝐵𝑚)=  𝑃்௑−𝐿௖௔௕௟௘+𝐺௔௡௧௘௡௡௔ 
From section 3.5.4, ground station receiver characteristics and path parameters are defined as: 
RX polarization loss = -3 dB, Line Loss = -1 dB, and total propagation loss is -119.26 dB (from 
section 3.5.2) 
By substituting (i) into (eq. A) from section 3.5.4,  
-83.60 dBm = minimum EIRP + Total Propagation Loss + Total GRX – Total LRX 
-83.60 dBm = minimum EIRP + (-119.26 dB) + (19.0 dBi) + (- 3.0 dB - 1.0 dB) 
minimum EIRP = 20.66 dBm 
 Thus, the airborne transmitter configuration must achieve a minimum EIRP of 20.66 
dBm to close the link under worst-case operational conditions. 
Additionally, the link budget can also be analyzed from the perspective of the airborne 
transmitter components using the standard EIRP definition:  
𝐸𝐼𝑅𝑃(𝑑𝐵𝑚)=  𝑃்௑−𝐿௖௔௕௟௘+𝐺௔௡௧௘௡௡௔,  
To reconcile the actual hardware performance with the required baseline of 20.66 dBm, the 
minimum required transmitter antenna gain (GTX) must satisfy: 
𝑚𝑖𝑛𝑖𝑚𝑢𝑚 𝑃்௑≥  𝐸𝐼𝑅𝑃(𝑑𝐵𝑚)+𝐿௖௔௕௟௘−𝐺௔௡௧௘௡௡௔ 
𝒎𝒊𝒏𝒊𝒎𝒖𝒎 𝑮𝑨𝒏𝒕𝒆𝒏𝒏𝒂≥𝟕.𝟔𝟔 𝒅𝑩𝒊 

--- PAGE 20 ---

20 
 
Linear Antenna Gain = 10
ళ.లల ೏ಳ೔
భబ = 5.834 
The transmitted power output at the output port of the UA V RF transmitter is 7.66 dBi, or 5.834. 
Here’s the summary of the minimum EIRP requirement for UA V to establish link with a 
minimum of 31.5 dBm link margin:  
Table 8: UAV Communication System EIRP Summary 
 
4.6 Required Antenna Gain Adjustment Table 
Since the UA V communication system must maintain a strict minimum realized gain of 
7.66 dBi to close the link budget with your required 31.5 dB margin, you must over-design the 
antenna's physical structure, the following UA V antenna must follow the specification below 
based on its efficiency rating: 
Table 9: Adjusted Antenna Gain due to Antenna Efficiency Factor operating at 290K: 
Antenna 
Efficiency 
(%) 
Required Minimum 
Realized Gain (dBi) 
 
Internal Heat 
Loss (dB) 
Required 
Designed Base 
Gain (dBi) 
Equivalent 
Linear Gain 
Ratio 
100% 7.66 dBi 0.00 dB 7.66 dBi 5.834 
95% 7.66 dBi 0.22 dB 7.88 dBi 6.138 
90% 7.66 dBi 0.46 dB 8.12 dBi 6.486 
85% 7.66 dBi 0.71 dB 8.37 dBi 6.871 
80% 7.66 dBi 0.97 dB 8.63 dBi 7.294 
 
OperationUnits ValueTx Power, Ptx + dBm 15.00Tx component line losses, L_T,Line + dB -1.00Tx antenna gain, Gt  (minimum)+dBi7.66Tx pointing loss, L_T,point + dB 0.00Tx radome loss, L_T,radome + dB -1.00EIRP  (minimum)dBm20.66UAV Transmitter

--- PAGE 21 ---

21 
 
4.7 Minimum requirements for UA V Communication System (Link Budget)  
Here is the summary of the minimum requirement to establish UA V communication link 
with a minimum net link margin of 31.50 dB: 
Table 10: Link Budget meets minimum net link margin of 31.50 dB 
 
ParametersFrequency 1060.5 MHzModulation Data Rate (Rdata) 138000 bits/sBandwidth, B 120000 HzWavelength 0.927487 ftTx Power 15 dBmUAS Antenna Gain (minimum)7.66dBiControl Station Antenna Gain 19 dBiRange, R 10 NMRequired Eb/No 3.5 dB

--- PAGE 22 ---

22 
 
 
OperationUnits ValueTx Power, Ptx + dBm 15.00Tx component line losses, L_T,Line + dB -1.00Tx antenna gain, Gt  (minimum)+dBi7.66Tx pointing loss, L_T,point + dB 0.00Tx radome loss, L_T,radome + dB -1.00EIRP  (minimum)dBm20.66Free space path loss + dB -118.31Atospheric absorption, L_P,Atm + dB -0.93Precipitation absorption, L_P, Precip + dB -0.02Total Propagaton LossdB -119.26Rx peak antenna gain, G_R + dBi 19.00Rx polarizaton loss, L_R, Polar + dB -3.00Rx pointing Loss, L_R,Point + dB 0.00Rx radome loss, L_R, Radome + dB 0.00Rx component line losses, L_R, Line + dB -1.00Spreading implemetation loss, L_R,Spread + dB 0.00Effective carrier power  (minimum)dBm-83.60Thermal noise density, kT @ 290K - dBm/Hz -174.00Rx noise bandwidth, BW - dBHz 50.79Rx noise figure, NF - db 4.00Effective noise power- dBm -119.21Available SNR  (minimum)dB35.61Required SNR dB 4.11Net signal margin (link margin)  (minimum)dB31.50
UAV TransmitterPropagationLCS-2 Control Station (Receiver)NoiseSummary

--- PAGE 23 ---

23 
 
4.8 Link Budget Requirements Allocation (RF LOS) 
To successfully establish and maintain continuous communication, an additional margin 
is added to the link budget to account for unforeseen RF losses. Consequently, the overall link 
margin requirements allocation is updated to 35 dB. 
Table 11: Link Budget Allocation 
 
ParametersFrequency 1060.5 MHzModulation Data Rate (Rdata) 138000 bits/sBandwidth, B 120000 HzWavelength 0.927487 ftTx Power 15 dBmUAS Antenna Gain11.155dBiControl Station Antenna Gain 19 dBiRange, R 10 NMRequired Eb/No 3.5 dBOperationUnits ValueTx Power, Ptx + dBm 15.00Tx component line losses, L_T,Line + dB -1.00Tx antenna gain, Gt + dBi 11.16Tx pointing loss, L_T,point + dB 0.00Tx radome loss, L_T,radome + dB -1.00EIRPdBm 24.16Free space path loss + dB -118.31Atospheric absorption, L_P,Atm + dB -0.93Precipitation absorption, L_P, Precip + dB -0.02Total Propagaton LossdB -119.26Rx peak antenna gain, G_R + dBi 19.00Rx polarizaton loss, L_R, Polar + dB -3.00Rx pointing Loss, L_R,Point + dB 0.00Rx radome loss, L_R, Radome + dB 0.00Rx component line losses, L_R, Line + dB -1.00Spreading implemetation loss, L_R,Spread + dB 0.00Effective carrier powerdBm -80.10Thermal noise density, kT @ 290K - dBm/Hz -174.00Rx noise bandwidth, BW - dBHz 50.79Rx noise figure, NF - db 4.00Effective noise power- dBm -119.21Available SNR dB 39.11Required SNR dB 4.11Net signal margin (link margin)dB35.00
UAV TransmitterPropagationLCS-2 Control Station (Receiver)NoiseSummary

--- PAGE 24 ---

24 
 
And the Adjusted Antenna Gain due to Antenna Efficiency Factor operating at 290K is as follow:  
Table 12: Antenna Base Gain and Realized Gain 
Antenna 
Efficiency 
(%) 
Required Minimum 
Realized Gain (dBi) 
 
Internal Heat 
Loss (dB) 
Required 
Designed Base 
Gain (dBi) 
Equivalent 
Linear Gain 
Ratio 
100% 11.15 dBi 0.00 dB 11.155 13.047 
95% 11.15 dBi 0.22 dB 11.378 13.733 
90% 11.15 dBi 0.46 dB 11.613 14.496 
85% 11.15 dBi 0.71 dB 11.861 15.349 
80% 11.15 dBi 0.97 dB 12.124 16.308 
 
Based on the link budget analysis and the UA V antenna configuration with a minimum Peak 
Directive Gain(GT) of 12.124 dBi and an efficiency of 80% is selected for this operation, 
yielding a net transmitter gain of 11.15 dBi, as specified in [CM-4]. 
4.9 Link Budget Prediction based on Hardware selection (RF LOS) 
Following the selection of the UA V antenna, the RF Line-of-Sight (LOS) link budget was 
updated to predict baseline system performance. Please refer to Section 7: Hardware Selection 
Summary) for the hardware parameters used in this Link Budget Prediction update. 
4.10 Link Budget Prediction results 
The resulting predictive analysis, detailed below, verifies signal viability using the finalized 
hardware parameters, as defined and captured in Section 7.1: Final System parameters.  

--- PAGE 25 ---

25 
 
Table 13: Link Budget Prediction results 
 
 
ParametersFrequency 1060.5 MHzModulation Data Rate (Rdata) 138000 bits/sBandwidth, B 120000 HzWavelength 0.927487 ftTx Power 15 dBmUAV Antenna Gain (Realized) GTX 13.155 dBiUAV Antenna Designed Base Gain (GTx) 14.124 dBiAnteanna Efficiency80 %Control Station Antenna Gain 19 dBiRange, R 10 NMRequired Eb/No 3.5 dBOperationUnits ValueTx Power, Ptx + dBm 15.00Tx component line losses, L_T,Line + dB -1.00Tx antenna gain, Gt + dBi 13.16Tx pointing loss, L_T,point + dB -0.10Tx radome loss, L_T,radome + dB -0.50EIRPdBm 26.56Free space path loss + dB -118.31Atospheric absorption, L_P,Atm + dB -0.93Precipitation absorption, L_P, Precip + dB -0.02Total Propagaton LossdB -119.26Rx peak antenna gain, G_R + dBi 19.00Rx polarizaton loss, L_R, Polar + dB -3.00Rx pointing Loss, L_R,Point + dB 0.00Rx radome loss, L_R, Radome + dB 0.00Rx component line losses, L_R, Line + dB -1.00Spreading implemetation loss, L_R,Spread + dB 0.00Effective carrier powerdBm -77.70Thermal noise density, kT @ 290K - dBm/Hz -174.00Rx noise bandwidth, BW - dBHz 50.79Rx noise figure, NF - db 4.00Effective noise power- dBm -119.21Available SNR dB 41.51Required SNR dB 4.11Net signal margin (link margin)dB37.40
UAV TransmitterPropagationLCS-2 Control Station (Receiver)NoiseSummary

--- PAGE 26 ---

26 
 
5.0 Post-Link Budget Simulation, Analysis and Specification Updates 
Following the finalization of the link budget design, allocation parameters, and 
performance predictions, the system analysis has been revised to reflect these completed baseline 
metrics. The comprehensive updates and corresponding technical evaluations are detailed in 
section 7: Final requirement specifications. 
5.1 Post Update: UA V RF Coverage Analysis & RF LOS Re-validation 
After finalizing the UA V communication system design, the updated antenna hardware 
specifications, waypoints from the navigation plan (NavPlan), and core design criteria are 
imported into MATLAB to execute the RF coverage analysis. Rain antennation and 
environmental losses are factored into the RF coverage analysis to model realistic environment. 
The simulation is generated using the following parameters: 
 


--- PAGE 27 ---

27 
 
Figure 5: UAV RF Coverage Analysis 
 
The MATLAB coverage analysis confirms that the system successfully establishes a robust RF 
link throughout the specified operational footprint, validating the viability of the communication 
design. 
Figure 6: UAV RF Coverage Analysis: LCS-2 View 
 


--- PAGE 28 ---

28 
 
Figure 7: UAV RF Coverage Analysis: Mission Loiter View 
 
   
 
  


--- PAGE 29 ---

29 
 
6.0 Requirements Refinement & Final Requirements Specification 
Following the finalization of the link budget design, allocation parameters, and performance 
predictions, the system requirements have been revised to reflect these design updates. The final 
requirements specification is detailed in the table below. 
Table 14 
UAV System Requirement Specification (SRS): Communication System Subset 
Object 
ID Object Type Requirement Traceability Compliance 
Status 
UAV System Requirement SpeciﬁcaƟon (SRS) 
UAV CommunicaƟon System     
UAV-1 
Performance 
The communicaƟon system shall maintain a minimum 
end-to-end link margin of 35.0 dB under worst-case 
operaƟonal and environmental condiƟons. 
CM-1, CM-3, 
CM-4, CM-5, 
CM-6, CM-7, 
CM-8 Comply 
UAV-2 
Performance 
The communicaƟon system shall achieve a link 
availability of no less than 97% over the designated 
geographic operaƟonal region.   
Comply  
(Sec 5.1) 
UAV-3 
Performance 
The communicaƟon system shall deliver user data at a 
maximum baseband Bit Error Rate (BER) of 1x10^-6 at 
the maximum operaƟonal range. CM-2 Comply 
 
  

--- PAGE 30 ---

30 
 
Table 15 
Communication subsystem specification 
Object 
ID Object Header Requirement Text Object Type Ver. 
Method 
Compliance 
Value Ver. Evidence 
UAV CommunicaƟon Subsystem SpeciﬁcaƟon 
RF subsystem Performance Requirements 
CM-1 
Link Margin 
The UAS communicaƟon 
subsystem shall maintain a 
minimum Net Signal 
Margin of 35.0 dB under 
worst-case operaƟonal 
condiƟons, including 
maximum operaƟonal 
range, adverse 
atmospheric aƩenuaƟon, 
and worst-case aircraŌ 
aƫtude. Performance  
Analysis, 
Test 37.40 dB SecƟon 3: Link 
Budget Design 
CM-2 
Bit Error Rate 
The ground staƟon receiver 
demodulator shall 
successfully demodulate 
and decode incoming 
bitstreams with a 
maximum Bit Error Rate 
(BER) of 10-6 at a minimum 
received Eb/N0 threshold 
of 3.5 dB, inclusive of all 
internal modem 
implementaƟon losses. Performance 
Analysis, 
Test 
Eb/N0 
3.5dB, BER 
10-6 
 (Veriﬁed 
by design) 
SecƟon 3: Link 
Budget Design; 
Hardware 
speciﬁcaƟon 
CM-3 
Receiver Noise 
Bandwidth 
The communicaƟon 
subsystem receiver shall 
operate with a total noise 
bandwidth (BW) of 50.79 
dBHz +/- 0.15 dB 
(equivalent to 120 kHz). Performance 
Analysis, 
Test 
50.79 dBHz 
(Veriﬁed by 
design) 
SecƟon 3: Link 
Budget Design; 
Hardware 
speciﬁcaƟon 
UAV TransmiƩer Hardware Requirements 
CM-4 
TransmiƩer 
Output Power 
The UAV RF transmiƩer 
shall provide a minimum 
conƟnuous conducted 
output power (P_TX) of 
15.0 dBm at the output 
port. Performance  
Analysis, 
Test 
15.0 dBm 
(Veriﬁed by 
design) 
SecƟon 3: Link 
Budget Design; 
Hardware 
speciﬁcaƟon 

--- PAGE 31 ---

31 
 
Object 
ID Object Header Requirement Text Object Type Ver. 
Method 
Compliance 
Value Ver. Evidence 
CM-5 
TransmiƩer 
Antenna Gain 
The UAV transmiƩer 
antenna shall provide a 
minimum Peak DirecƟve 
Gain (G_T) of 11.16 dBi 
with 80% antenna 
eﬃciency within the 
operaƟonal frequency 
band.  Performance  
Analysis, 
Test 13.16 dBi 
SecƟon 3: Link 
Budget Design; 
Hardware 
speciﬁcaƟon 
CM-6 Equivalent 
Isotropic 
Radiated Power 
(EIRP) 
The integrated airborne 
subsystem shall achieve a 
minimum EIRP of 24.16 
dBm.  Performance  
Analysis, 
Test 25.56 dBm SecƟon 3: Link 
Budget Design 
LCS-2 Ground Control StaƟon Subsystem Requirements 
CM-7 
Receiver 
Antenna Gain 
The LCS-2 Control StaƟon 
receiver antenna shall 
provide a peak direcƟve 
gain (G_RX) of at least 
19.00 dBi along the 
tracking boresight.  Performance 
Analysis, 
Test 
19.00 dBi 
(Veriﬁed by 
design) 
SecƟon 3: Link 
Budget Design; 
Hardware 
speciﬁcaƟon 
CM-8 Receiver Noise 
Figure 
The ground staƟon receiver 
system Noise Figure shall 
not exceed 4.00 dB.  Performance 
Analysis, 
Test 
4.00 dB 
(Veriﬁed by 
design) 
SecƟon 3: Link 
Budget Design; 
Hardware 
speciﬁcaƟon 
RF subsystem FuncƟonal Requirements 
CM-9 
RF Interference 
The communicaƟon 
subsystem shall account for 
mulƟpath and mariƟme RF 
interference.   FuncƟonal InspecƟon 
- SecƟon 3: Link 
Budget Design 
CM-10 CommunicaƟon 
Standards 
The communicaƟon 
subsystem shall be 
compaƟble with DO 362 L 
Band datalink standards.   FuncƟonal InspecƟon 
- SecƟon 3: Link 
Budget Design 
 
 
 
 
  

--- PAGE 32 ---

32 
 
7.0 Final Design Specification 
The UA V communication system design has been successfully validated against the mission 
requirements for a VTOL-based ISR platform operating from an LCS-2 ship in the South China 
Sea. The link budget analysis, combined with hardware selection and terrain validation, confirms 
that the system is capable of maintaining a robust, reliable command-and-control link with a 
minimum net signal margin of 35.0 dB. The following section summarizes the final hardware 
specifications, link budget parameters, and key design decisions. 
7.1 Final System Parameters 
Table 16 
Final System Parameters 
Parameter Value Units 
Operating Frequency (f)  1060.5 MHz 
Modulation Data Rate (Rdata) 138,000 bits/s 
Channel Bandwidth (B) 120,000 Hz 
Wavelength (λ) 0.9275 ft 
Transmitter Output Power (PTX) 15 dBm 
UA V Antenna Gain (Realized) GTX 13.155 dBi 
UA V Antenna Designed Base Gain (GTx) 14.124 dBi 
UA V Antenna Efficiency (η) 80 % 
LCS-2 Receiver Antenna Gain (GRX) 19 dBi 
Operational Range (R) 10 NM 
Required Eb/No 3.5 dB 
System Noise Figure (NF) 4 dB 
 
  

--- PAGE 33 ---

33 
 
7.2 Final Link Budget Summary 
Table 17 
Final Link Budget (Design / Prediction) Summary 
    Operation Units Value 
UAV 
Transmitter 
Tx Power, Ptx + dBm 15.00  
Tx component line losses, L_T,Line + dB -1.00  
Tx antenna gain, Gt + dBi 13.16  
Tx pointing loss, L_T,point + dB -0.10  
Tx radome loss, L_T,radome + dB -0.50  
EIRP   dBm 26.56  
          
Propagation 
Free space path loss + dB -118.31  
Atospheric absorption, L_P,Atm + dB -0.93  
Precipitation absorption, L_P, Precip + dB -0.02  
Total Propagaton Loss   dB -119.26  
          
LCS-2 
Control 
Station 
(Receiver) 
Rx peak antenna gain, G_R + dBi 19.00  
Rx polarizaton loss, L_R, Polar + dB -3.00  
Rx pointing Loss, L_R,Point + dB 0.00  
Rx radome loss, L_R, Radome + dB 0.00  
Rx component line losses, L_R, Line + dB -1.00  
Spreading implemetation loss, L_R,Spread + dB 0.00  
Effective carrier power   dBm -77.70  
          
Noise 
Thermal noise density, kT @ 290K - dBm/Hz -174.00  
Rx noise bandwidth, BW - dBHz 50.79  
Rx noise figure, NF - db 4.00  
Effective noise power - dBm -119.21  
          
Summary 
Available SNR   dB 41.51  
Required SNR   dB 4.11  
Net signal margin (link margin)   dB 37.40 
 
  

--- PAGE 34 ---

34 
 
Table 18 
Final Link Budget (Baseline, Prediction and Allocation) Summary 
 
7.3 Hardware Selection Summary 
7.3.1 Airborne Transmitter Equipment 
Component Specification Rationale 
RF 
Transmitter 
15.0 dBm output, 1060.5 MHz, GMSK 
modulation 
Provides sufficient power to meet 
24.16 dBm EIRP requirement 
Power 
Amplifier 0.5 W, L-band, 80% efficiency 
Maintains low power 
consumption while ensuring link 
closure 
Dipole 
Antenna 
13.155 dBi peak gain, omnidirectional 
horizontal pattern 
Ensures continuous coverage 
during all bank angles; eliminates 
pointing requirements 
Coaxial 
Cable 
Low-loss LMR-400, 3 ft length, 0.5 
dB/ft loss 
Minimizes insertion losses to 
maintain EIRP 
 
  
OperationUnitsAntenna Hardware Prediction (37 dB)Requirements Allocation (35dB)Baseline (31.5dB)Margin =  Prediction - BaselineMargin = Prediction - AllocationTx Power, Ptx + dBm 15.00 15.00 15.00 0.00 0.00Tx component line losses, L_T,Line + dB -1.00 -1.00 -1.00 0.00 0.00Tx antenna gain, Gt + dBi 13.16 11.16 7.66 5.50 2.00Tx pointing loss, L_T,point + dB -0.10 0.00 0.00 -0.10 -0.10Tx radome loss, L_T,radome + dB -0.50 -1.00 -1.00 0.50 0.50EIRPdBm 26.56 24.16 20.66 5.90 2.40Free space path loss + dB -118.31 -118.31 -118.31 0.00 0.00Atospheric absorption, L_P,Atm + dB -0.93 -0.93 -0.93 0.00 0.00Precipitation absorption, L_P, Precip + dB -0.02 -0.02 -0.02 0.00 0.00Total Propagaton LossdB -119.26 -119.26 -119.26 0.00 0.00Rx peak antenna gain, G_R + dBi 19.00 19.00 19.00 0.00 0.00Rx polarizaton loss, L_R, Polar + dB -3.00 -3.00 -3.00 0.00 0.00Rx pointing Loss, L_R,Point + dB 0.00 0.00 0.00 0.00 0.00Rx radome loss, L_R, Radome + dB 0.00 0.00 0.00 0.00 0.00Rx component line losses, L_R, Line + dB -1.00 -1.00 -1.00 0.00 0.00Spreading implemetation loss, L_R,Spread + dB 0.00 0.00 0.00 0.00 0.00Effective carrier powerdBm -77.70 -80.10 -83.60 5.90 2.40Thermal noise density, kT @ 290K - dBm/Hz -174.00 -174.00 -174.00 0.00 0.00Rx noise bandwidth, BW - dBHz 50.79 50.79 50.79 0.00 0.00Rx noise figure, NF - db 4.00 4.00 4.00 0.00 0.00Effective noise power- dBm -119.21 -119.21 -119.21 0.00 0.00Available SNR dB 41.51 39.11 35.61 5.90 2.40Required SNR dB 4.11 4.11 4.11 0.00 0.00Net signal margin (link margin)dB37.40 35.00 31.50 5.90 2.40UAV TransmitterPropagationLCS-2 Control Station (Receiver)NoiseSummary

--- PAGE 35 ---

35 
 
7.3.2 LCS-2 Ground Station Equipment 
Component Specification Rationale 
Parabolic 
Dish Antenna 
19.0 dBi gain, 18° beamwidth, 1.5 m 
diameter 
High gain ensures strong received 
signal; narrow beamwidth permits 
precise tracking 
Gimbal 
System 
2-axis, ±45° elevation, 360° azimuth, 
5°/s slew rate 
Enables rapid acquisition and 
continuous tracking of maneuvering 
UA V 
LNA 
Noise Figure ≤4.0 dB, L-band, 40 dB 
gain 
Maintains low noise floor while 
boosting signal for demodulation 
Demodulator 
GMSK compatible, 138 kbps, ≤1×10⁻⁶ 
BER 
Meets data rate and error rate 
requirements for reliable link 
7.4 Design Verification Summary 
Requirement ID Description Status 
CM-1 
Maintain minimum Net Signal Margin 
of 35.0 dB Verified (37.40 dB, achieved) 
CM-2 
BER of 10⁻⁶ at Eb/No threshold of 3.5 
dB Verified 
CM-4 Transmitter Output Power ≥ 15.0 dBm Verified 
CM-5 
UA V Antenna Gain ≥ 12.124 dBi (80% 
efficiency) Verified (13.155 dBi selected) 
CM-6 Minimum EIRP ≥ 24.16 dBm Verified (26.55 dBm achieved) 
CM-7 
Control Station Antenna Gain ≥ 19.0 
dBi Verified 
CM-8 Receiver Noise Figure ≤ 4.00 dB Verified 
 
  

--- PAGE 36 ---

36 
 
6.0 Conclusion 
The UAV communication system design has been successfully validated against all mission 
requirements for VTOL-based ISR operations from an LCS-2 ship in the South China Sea. The 
link budget analysis confirms that the system achieves a net signal margin of 37.40 dB, 
exceeding the 35.0 dB requirement by 2.40 dB. This margin provides adequate protection against 
environmental degradations such as tropical precipitation, atmospheric absorption, and potential 
RF interference in this contested electromagnetic environment. 
The selected hardware configuration, a 15.0 dBm airborne transmitter with a 13.155 dBi 
omnidirectional antenna and a shipboard 19.0 dBi parabolic dish, satisfies all derived 
requirements while maintaining positive link closure at the 10 NM operational range. The dual-
link architecture (LOS primary with BLOS backup) ensures continuous command and control 
across all mission phases, with seamless failover capability. 
All key performance parameters, including BER (≤1×10⁻⁶), EIRP (26.55 dBm), and receiver 
noise figure (4.0 dB), meet or exceed their specified thresholds. The design demonstrates that a 
robust, reliable communication link can be established and maintained even under the 
challenging conditions of the South China Sea theater, enabling successful execution of the ISR 
mission. 
  

--- PAGE 37 ---

37 
 
References 
Embry-Riddle Aeronautical University (n.d.). Group Project #2: UAS Avionics, Autonomy, and 
Datalink Analysis (UASE 501: Introduction to Unmanned Aircraft Design) [Course 
assignment]. Embry-Riddle Aeronautical University Canvas.  
Federal Communications Commission. (2024). Federal Code of Regulations: Online table of 
frequency allocations. U.S. Department of Commerce. 
https://www.fcc.gov/sites/default/files/fcctable.pdf 
International Telecommunication Union. (2014). Guidelines for the preparation of a National 
Table of Frequency Allocations (ITU-D Spectrum Management Publication). 
https://www.itu.int/en/ITU-D/Spectrum-
Broadcasting/Documents/Publications/Guidelines-NTFA-E.pdf 
ITU-R. (2005). Specific attenuation model for rain for use in prediction methods 
(Recommendation ITU-R P.838-3). International Telecommunication Union. 
RTCA. (2016). Command and control (C2) data link minimum operational performance 
standards (MOPS) (terrestrial) (RTCA DO-362). RTCA Special Committee 228.  
SBS News. (2024, June 9). South China Sea dispute | SBS Explained [Video]. YouTube. 
https://www.youtube.com/watch?v=sq_hj-bcYzw 
Heywood, J. (2019, April 3). China's economic cabbage strategy. Asia Maritime Transparency 
Initiative. https://amti.csis.org/chinas-economic-cabbage-strategy/ 
Center for Maritime Strategy. (2024, June 20). Deterring China's salami tactics. 
https://centerformaritimestrategy.org/publications/south-china-sea-deterrence-project/ 

--- PAGE 38 ---

38 
 
Council on Foreign Relations. (2026, May 14). Territorial disputes in the South China Sea. 
Global Conflict Tracker. https://www.cfr.org/global-conflict-tracker/conflict/territorial-
disputes-south-china-sea 
AIM Online. (n.d.). AFDX®/ARINC664P7 Tutorial. https://www.aim-online.com/products-
overview/tutorials/afdx-arinc664p7-tutorial/  
Young, L. A., Yetter, J. A., & Guynn, M. D. (2006, September 19). System analysis applied to 
autonomy: Application to high-altitude long-endurance remotely operated aircraft. 
National Aeronautics and Space Administration. 
https://ntrs.nasa.gov/citations/20090027657  
The MathWorks. (n.d.). Analyze coverage and view results. MathWorks Help Center. Retrieved 
July 4, 2026, from https://www.mathworks.com/help/slcoverage/analyze-coverage-and-
view-results.html 
The MathWorks. (n.d.). Model coverage. MathWorks Help Center. Retrieved July 4, 2026, from 
https://www.mathworks.com/help/slcoverage/ug/model-coverage.html 
The MathWorks. (n.d.). WaypointTrajectory system object. MathWorks Help Center. Retrieved 
July 4, 2026, from https://www.mathworks.com/help/nav/ref/waypointtrajectory-system-
object.html 