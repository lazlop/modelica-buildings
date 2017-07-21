within Buildings.Experimental.OpenBuildingControl.ASHRAE.G36.Atomic.Validation;
model EconEnableDisableSingleZone_TOut_hOut
  "Model validates economizer disable in case outdoor air conditions are above cutoff"
  extends Modelica.Icons.Example;

  parameter Modelica.SIunits.Temperature TOutCutoff=297
    "Outdoor temperature high limit cutoff";
  parameter Modelica.SIunits.SpecificEnergy hOutCutoff=65100
    "Outdoor air enthalpy high limit cutoff";
  parameter Types.FreezeProtectionStage freProDisabled = Types.FreezeProtectionStage.stage0
    "Indicates that the freeze protection is disabled";
  parameter Integer freProDisabledNum = Integer(freProDisabled)-1
    "Numerical value for freeze protection stage 0 (=0)";
  parameter Types.ZoneState deadband = Types.ZoneState.deadband
    "Zone state is deadband";
  parameter Integer deadbandNum = Integer(deadband)
    "Numerical value for deadband zone state (=2)";

  CDL.Continuous.Sources.Constant TOutCut(k=TOutCutoff) "Outdoor air temperature cutoff"
    annotation (Placement(transformation(extent={{-160,40},{-140,60}})));
  CDL.Continuous.Sources.Constant hOutCut(k=hOutCutoff) "Outdoor air enthalpy cutoff"
    annotation (Placement(transformation(extent={{-240,0},{-220,20}})));
  CDL.Continuous.Sources.Constant TOutCut1(k=TOutCutoff) "Outdoor air temperature cutoff"
    annotation (Placement(transformation(extent={{0,40},{20,60}})));
  CDL.Continuous.Sources.Constant hOutCut1(k=hOutCutoff) "Outdoor air enthalpy cutoff"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  CDL.Continuous.Sources.Constant hOutBelowCutoff(k=hOutCutoff - 1000)
    "Outdoor air enthalpy is slightly below the cufoff"
    annotation (Placement(transformation(extent={{-240,40},{-220,60}})));
  CDL.Continuous.Sources.Constant TOutBellowCutoff(k=TOutCutoff - 2)
    "Outdoor air temperature is slightly below the cutoff"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  CDL.Logical.TriggeredTrapezoid TOut(
    rising=1000,
    falling=800,
    amplitude=4,
    offset=TOutCutoff - 2) "Outoor air temperature"
    annotation (Placement(transformation(extent={{-160,80},{-140,100}})));
  CDL.Logical.TriggeredTrapezoid hOut(
    amplitude=4000,
    offset=hOutCutoff - 2200,
    rising=1000,
    falling=800) "Outdoor air enthalpy"
    annotation (Placement(transformation(extent={{-40,40},{-20,60}})));

  EconEnableDisableSingleZone ecoEnaDis "Singlezone VAV AHU economizer enable disable sequence"
    annotation (Placement(transformation(extent={{-80,-80},{-60,-60}})));
  EconEnableDisableSingleZone ecoEnaDis1 "Singlezone VAV AHU economizer enable disable sequence"
    annotation (Placement(transformation(extent={{80,-80},{100,-60}})));
  EconEnableDisableSingleZone ecoEnaDis2(use_enthalpy=false) "Singlezone VAV AHU economizer enable disable sequence"
    annotation (Placement(transformation(extent={{220,-80},{240,-60}})));

protected
  CDL.Integers.Sources.Constant ZoneState(k=deadbandNum) "Zone State is deadband"
    annotation (Placement(transformation(extent={{-200,-50},{-180,-30}})));
  CDL.Continuous.Sources.Constant outDamPosMax(k=0.9) "Maximal allowed economizer damper position"
    annotation (Placement(transformation(extent={{-240,-120},{-220,-100}})));
  CDL.Continuous.Sources.Constant outDamPosMin(k=0.1) "Minimal allowed economizer damper position"
    annotation (Placement(transformation(extent={{-240,-160},{-220,-140}})));
  CDL.Integers.Sources.Constant FreProSta(k=freProDisabledNum) "Freeze Protection Status - Disabled"
    annotation (Placement(transformation(extent={{-200,-20},{-180,0}})));
  CDL.Logical.Sources.Pulse booPul(final startTime=10, period=2000) "Boolean pulse signal"
    annotation (Placement(transformation(extent={{-200,80},{-180,100}})));
  CDL.Logical.Sources.Pulse booPul1(final startTime=10, period=2000) "Boolean pulse signal"
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  CDL.Logical.Sources.Constant SupFanSta(k=true) "Supply fan status signal"
      annotation (Placement(transformation(extent={{-200,-80},{-180,-60}})));

equation
  connect(TOutCut.y, ecoEnaDis.TOutCut)
    annotation (Line(points={{-139,50},{-112,50},{-112,-62},{-81,-62}}, color={0,0,127}));
  connect(hOutCut.y, ecoEnaDis.hOutCut)
    annotation (Line(points={{-219,10},{-150,10},{-150,-66},{-81,-66}}, color={0,0,127}));
  connect(FreProSta.y, ecoEnaDis.uFreProSta)
    annotation (Line(points={{-179,-10},{-120,-10},{-120,-68},{-81,-68}}, color={255,127,0}));
  connect(outDamPosMax.y, ecoEnaDis.uOutDamPosMax)
    annotation (Line(points={{-219,-110},{-150,-110},{-150,-74},{-81,-74}}, color={0,0,127}));
  connect(outDamPosMin.y, ecoEnaDis.uOutDamPosMin)
    annotation (Line(points={{-219,-150},{-210,-150},{-210,-100},{-140,-100},{-140,-76},{-81,-76}}, color={0,0,127}));
  connect(ecoEnaDis.uZonSta, ZoneState.y)
    annotation (Line(points={{-81,-70},{-140,-70},{-140,-40},{-179,-40}}, color={255,127,0}));
  connect(TOutCut1.y, ecoEnaDis1.TOutCut)
    annotation (Line(points={{21,50},{30,50},{30,-62},{79,-62}}, color={0,0,127}));
  connect(hOutCut1.y, ecoEnaDis1.hOutCut)
    annotation (Line(points={{-59,10},{10,10},{10,-66},{79,-66}}, color={0,0,127}));
  connect(hOutBelowCutoff.y, ecoEnaDis.hOut)
    annotation (Line(points={{-219,50},{-180,50},{-180,26},{-130,26},{-130,-64},{-81,-64}}, color={0,0,127}));
  connect(TOutBellowCutoff.y, ecoEnaDis1.TOut)
    annotation (Line(points={{61,50},{70,50},{70,-60},{80,-60},{79,-60}}, color={0,0,127}));
  connect(booPul.y, TOut.u)
    annotation (Line(points={{-179,90},{-162,90}},   color={255,0,255}));
  connect(TOut.y, ecoEnaDis.TOut) annotation (Line(points={{-139,90},{-110,90},{-110,-60},{-81,-60}}, color={0,0,127}));
  connect(booPul1.y, hOut.u) annotation (Line(points={{-59,50},{-50,50},{-42,50}}, color={255,0,255}));
  connect(hOut.y, ecoEnaDis1.hOut)
    annotation (Line(points={{-19,50},{-10,50},{-10,20},{20,20},{20,-64},{79,-64}}, color={0,0,127}));
  connect(FreProSta.y, ecoEnaDis1.uFreProSta)
    annotation (Line(points={{-179,-10},{-30,-10},{-30,-68},{79,-68}}, color={255,127,0}));
  connect(ZoneState.y, ecoEnaDis1.uZonSta)
    annotation (Line(points={{-179,-40},{-160,-40},{-160,-26},{4,-26},{4,-70},{79,-70}}, color={255,127,0}));
  connect(outDamPosMax.y, ecoEnaDis1.uOutDamPosMax)
    annotation (Line(points={{-219,-110},{8,-110},{8,-74},{79,-74}}, color={0,0,127}));
  connect(outDamPosMin.y, ecoEnaDis1.uOutDamPosMin)
    annotation (Line(points={{-219,-150},{-190,-150},{-190,-104},{12,-104},{12,-76},{79,-76}}, color={0,0,127}));
  connect(TOut.y, ecoEnaDis2.TOut)
    annotation (Line(points={{-139,90},{-82,90},{200,90},{200,-60},{219,-60}}, color={0,0,127}));
  connect(TOutCut.y, ecoEnaDis2.TOutCut)
    annotation (Line(points={{-139,50},{-120,50},{-120,80},{188,80},{188,-62},{219,-62}}, color={0,0,127}));
  connect(FreProSta.y, ecoEnaDis2.uFreProSta)
    annotation (Line(points={{-179,-10},{170,-10},{170,-68},{219,-68}}, color={255,127,0}));
  connect(ZoneState.y, ecoEnaDis2.uZonSta)
    annotation (Line(points={{-179,-40},{-170,-40},{-170,-20},{150,-20},{150,-70},{219,-70}}, color={255,127,0}));
  connect(outDamPosMax.y, ecoEnaDis2.uOutDamPosMax)
    annotation (Line(points={{-219,-110},{180,-110},{180,-74},{219,-74}}, color={0,0,127}));
  connect(outDamPosMin.y, ecoEnaDis2.uOutDamPosMin)
    annotation (Line(points={{-219,-150},{-180,-150},{-180,-120},{190,-120},{190,-76},{219,-76}}, color={0,0,127}));
  connect(SupFanSta.y, ecoEnaDis.uSupFan)
    annotation (Line(points={{-179,-70},{-150,-70},{-150,-72},{-81,-72}}, color={255,0,255}));
  connect(SupFanSta.y, ecoEnaDis1.uSupFan)
    annotation (Line(points={{-179,-70},{-160,-70},{-160,-54},{-40,-54},{-40,-72},{79,-72}}, color={255,0,255}));
  connect(SupFanSta.y, ecoEnaDis2.uSupFan)
    annotation (Line(points={{-179,-70},{-170,-70},{-170,-50},{140,-50},{140,-72},{219,-72}}, color={255,0,255}));
  annotation (
  experiment(StopTime=1800.0, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/ASHRAE/G36/Atomic/Validation/EconEnableDisableSingleZone_TOut_hOut.mos"
    "Simulate and plot"),
  Icon(graphics={
        Ellipse(
          lineColor={75,138,73},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points={{-36,58},{64,-2},{-36,-62},{-36,58}})}), Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-260,-180},{260,180}}),
        graphics={Text(
          extent={{-234,166},{346,114}},
          lineColor={0,0,0},
          horizontalAlignment=TextAlignment.Left,
          textString="Example high limit cutoff conditions:
                      ASHRAE 90.1-2013:
                      Device Type: Fixed Enthalpy + Fixed Drybulb, Fixed Drybulb
                      TOut > 75 degF [24 degC]
                      hOut > 28 Btu/lb [65.1 kJ/kg]"),
        Text(
          extent={{-82,-80},{42,-108}},
          lineColor={0,0,0},
          horizontalAlignment=TextAlignment.Left,
          fontSize=12,
          textString="Tests temperature hysteresis"),
        Text(
          extent={{80,-80},{208,-108}},
          lineColor={0,0,0},
          horizontalAlignment=TextAlignment.Left,
          fontSize=12,
          textString="Tests enthalpy hysteresis"),
        Text(
          extent={{220,-86},{348,-114}},
          lineColor={0,0,0},
          horizontalAlignment=TextAlignment.Left,
          fontSize=12,
          textString="No enthalpy
sensor")}),
Documentation(info="<html>
<p>
This example validates
<a href=\"modelica://Buildings.Experimental.OpenBuildingControl.ASHRAE.G36.Atomic.EconEnableDisableSingleZone\">
Buildings.Experimental.OpenBuildingControl.ASHRAE.G36.Atomic.EconEnableDisableSingleZone</a>
for the following control signals: <code>TOut</code>, <code>TOutCut</code>,
<code>hOut</code>, <code>hOutCut</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
June 13, 2017, by Milica Grahovac:<br/>
First implementation.
</li>
</ul>
</html>"));
end EconEnableDisableSingleZone_TOut_hOut;
