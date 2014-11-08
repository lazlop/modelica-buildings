within Buildings.Fluid.FMI.BaseClasses;
model Outlet "Model for exposing a fluid outlet to the FMI interface"

  replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium "Medium model within the source"
     annotation (choicesAllMatching=true);

  parameter Boolean allowFlowReversal = true
    "= true to allow flow reversal, false restricts to design direction (inlet -> outlet)"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);

  Buildings.Fluid.FMI.Interfaces.Outlet outlet(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal) "Fluid outlet" annotation (Placement(transformation(extent={{
            100,-10},{120,10}}), iconTransformation(extent={{100,-10},{120,10}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium=Medium) "Fluid port"
                annotation (Placement(
        transformation(extent={{-110,-10},{-90,10}}),
                                                    iconTransformation(extent={{-110,
            -10},{-90,10}})));
  Modelica.Blocks.Interfaces.RealInput p(unit="Pa") "Pressure" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={0,-120})));
protected
  Buildings.Fluid.FMI.Interfaces.FluidProperties bacPro_internal(
    redeclare final package Medium = Medium)
    "Internal connector for fluid properties for back flow";
equation
  // Set outlet pressure and port pressure to pressure
  // of signal port
  outlet.p      = p;
  port_a.p      = p;
  port_a.m_flow = outlet.m_flow;

  inStream(port_a.h_outflow)  = outlet.forward.h;
  inStream(port_a.Xi_outflow) = outlet.forward.Xi;
  inStream(port_a.C_outflow)  = outlet.forward.C;

  // Conditional connector for flow reversal
  connect(outlet.backward, bacPro_internal);
  if not allowFlowReversal then
    bacPro_internal.h  = Medium.h_default;
    bacPro_internal.Xi = Medium.X_default[1:Medium.nXi];
    bacPro_internal.C  = fill(0, Medium.nC);
  end if;
  bacPro_internal.h  = port_a.h_outflow;
  bacPro_internal.Xi = port_a.Xi_outflow;
  bacPro_internal.C  = port_a.C_outflow;

    annotation (defaultComponentName="boundary",
    Icon(coordinateSystem(
        preserveAspectRatio=false,
        extent={{-100,-100},{100,100}}), graphics={
        Rectangle(
          extent={{60,60},{-60,-60}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={0,127,255}),
        Text(
          extent={{-150,110},{150,150}},
          textString="%name",
          lineColor={0,0,255}),
        Line(
          points={{60,0},{100,0}},
          color={0,0,255}),
        Rectangle(
          extent={{-100,20},{-60,-21}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255}),
        Text(
          extent={{66,40},{100,0}},
          lineColor={0,0,255},
          textString="outlet"),
        Line(
          points={{0,-60},{0,-100}},
          color={0,0,255},
          smooth=Smooth.None),
        Text(
          extent={{10,-64},{44,-104}},
          lineColor={0,0,255},
          textString="p")}),
    Documentation(info="<html>
<p>
Defines output values for boundary conditions:
</p>
<ul>
<li> Boundary pressure.</li>
<li> Boundary enthalpy.</li>
<li> Boundary composition (only for multi-substance or trace-substance flow).</li>
</ul>
<p>
This model can be used to send output signals from a fluid flow component
to the FMI interface.
</p>
</html>", revisions="<html>
<ul>
<li>
January 21, 2014 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics));
end Outlet;
