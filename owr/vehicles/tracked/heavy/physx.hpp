/// PhysX part

// diag_mergeConfigFile ["P:\owr\vehicles\tracked\heavy\config.cpp"]; diag_toggle "epevehicle";

simulation = "tankx";
enginePower = 100;
maxOmega = 276;
peakTorque = 2800;
torqueCurve[] = {
	//{ 0,0 },
	{ "(1600/2640)","(2650/2850)" },
	{ "(1800/2640)","(2800/2850)" },
	{ "(1900/2640)","(2850/2850)" },
	{ "(2000/2640)","(2800/2850)" },
	{ "(2200/2640)","(2750/2850)" },
	{ "(2400/2640)","(2600/2850)" },
	{ "(4900/2640)","(0/2850)" }
};
thrustDelay = 0.2;
clutchStrength = 10.0;
fuelCapacity = 1885;
brakeIdleSpeed = 1.78;
latency = 0.1;
tankTurnForce = 17000;
normalSpeedForwardCoef = 0.4;
idleRpm = 700;
redRpm = 2640;
engineLosses = 25;
transmissionLosses = 15;
//changeGearMinEffectivity[] = {0.5,0.15,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.9,0.9,0.9,0.9,0.9};
class complexGearbox {
	GearboxRatios[] = {
		"R1",-2.235,
		"N",0,
		"D1","2*(0.75^0)",
		"D2","2*(0.75^1)",
		"D3","2*(0.75^2)",
		"D4","2*(0.75^3)",
		"D5","2*(0.75^4)"
	};
	TransmissionRatios[] = {"High",20};	// 7.625
	gearBoxMode = "auto";
	moveOffGear = 1;
	driveString = "D";
	neutralString = "N";
	reverseString = "R";
	transmissionDelay = 0;
};

class Wheels {
	class L1 {
		boneName = "wheel_L1_track";
		center = "wheel_L_1_axis";
		boundary = "wheel_L_1_bound";
		damping = 1.0;
		steering = 0;
		side = "left";
		weight = 30;
		mass = 30;
		MOI = 1.404;
		latStiffX = 25;
		latStiffY = 280;
		longitudinalStiffnessPerUnitGravity = 100000;
		maxBrakeTorque = 1000;
		sprungMass = 375.0;
		springStrength = 7750;
		springDamperRate = 3200;
		dampingRate = 1.0;
		dampingRateInAir = 3010.0;
		dampingRateDamaged = 10.0;
		dampingRateDestroyed = 10000.0;
		maxDroop = 0.28;
		maxCompression = 0.28;
		frictionVsSlipGraph[] = {{ 0,5 },{ 0.5,5 },{ 1,5 }};
	};
	class L6: L1 {
		boneName = "wheel_L6_track";
		center = "wheel_L_6_axis";
		boundary = "wheel_L_6_bound";
	};
	class R1: L1 {
		boneName = "wheel_R1_track";
		center = "wheel_R_1_axis";
		boundary = "wheel_R_1_bound";
		side = "right";
	};
	class R6: R1 {
		boneName = "wheel_R6_track";
		center = "wheel_R_6_axis";
		boundary = "wheel_R_6_bound";
	};

/*

	class L2 {
		boneName = "wheel_L2_track";
		center = "wheel_L_2_axis";
		boundary = "wheel_L_2_bound";
		damping = 1.0;
		steering = 0;
		side = "left";
		weight = 10;
		mass = 10;
		MOI = 0.18818;
		latStiffX = 25;
		latStiffY = 280;
		longitudinalStiffnessPerUnitGravity = 100000;
		maxBrakeTorque = 1000;
		sprungMass = 95.0;
		springStrength = 5875;
		springDamperRate = 3300;
		dampingRate = 1.0;
		dampingRateInAir = 3010.0;
		dampingRateDamaged = 10.0;
		dampingRateDestroyed = 10000.0;
		maxDroop = 0.08;
		maxCompression = 0.08;
		frictionVsSlipGraph[] = {{ 0,5 },{ 0.5,5 },{ 1,5 }};
	};
	class L3: L2 {
		boneName = "wheel_L3_track";
		center = "wheel_L_3_axis";
		boundary = "wheel_L_3_bound";
	};
	class L4: L2 {
		boneName = "wheel_L4_track";
		center = "wheel_L_4_axis";
		boundary = "wheel_L_4_bound";
	};
	class L5: L2 {
		boneName = "wheel_L5_track";
		center = "wheel_L_5_axis";
		boundary = "wheel_L_5_bound";
	};
	class R2: L2 {
		boneName = "wheel_R2_track";
		center = "wheel_R_2_axis";
		boundary = "wheel_R_2_bound";
		side = "right";
	};
	class R3: R2 {
		boneName = "wheel_R3_track";
		center = "wheel_R_3_axis";
		boundary = "wheel_R_3_bound";
	};
	class R4: R2 {
		boneName = "wheel_R4_track";
		center = "wheel_R_4_axis";
		boundary = "wheel_R_4_bound";
	};
	class R5: R2 {
		boneName = "wheel_R5_track";
		center = "wheel_R_5_axis";
		boundary = "wheel_R_5_bound";
	};*/
};