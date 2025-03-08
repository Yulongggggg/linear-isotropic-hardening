#----------------
vertical_stress = 20e6
k = 1.3
inner_pressure = 6e6
#----------------
youngs_modulus_1 = 20e9
poissons_ratio_1 = 0.1
youngs_modulus_2 = 20e9
poissons_ratio_2 = 0.16
#----------------
coh_1 = 17e6
phi_1 = 41
psi_1 = 20
coh_2 = 2e6
phi_2 = 40
psi_2 = 20
#-----------------
# hardening_modulus_1 = 400e6
# hardening_modulus_2 = 400e6
#-----------------
compressive_strength_1 = 100e6
compressive_strength_2 = 100e6
#-----------------
# epsilon_0 = yield_strength / hardening modulus
epsilon_1 = 0.25
epsilon_2 = 0.25

[Mesh]
  file = 'bilayer.msh'
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables] #Block for the main variable (displacement), for auxiliary variables using [AxuVariables]
  [disp_x] # Define the interpolation functions
    order = FIRST
    family = LAGRANGE
  []
  [disp_y] # Define the interpolation functions
    order = FIRST
    family = LAGRANGE
  []
[]

[Functions]
  [vs_func]
    type = ParsedFunction
    expression = 'vertical_stress * t '
    symbol_names = 'vertical_stress'
    symbol_values = '${vertical_stress}'
  []
  [hs_func]
    type = ParsedFunction
    expression = 'k * vertical_stress * t'
    symbol_names = 'k vertical_stress'
    symbol_values = '${k} ${vertical_stress}'
  []
  [ip_func]
    type = ParsedFunction
    expression = 'inner_pressure * t '
    symbol_names = 'inner_pressure'
    symbol_values = '${inner_pressure}'
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL
        incremental = true
        add_variables = true
        generate_output = 'stress_xx stress_xy stress_yx stress_yy vonmises_stress strain_xx strain_xy strain_yy strain_yx PLASTIC_STRAIN_XX PLASTIC_STRAIN_XY PLASTIC_STRAIN_YY effective_plastic_strain'
        material_output_family = 'MONOMIAL'
        material_output_order = 'FIRST'
        block = 'block1 block2'
      []
    []
  []
[]

[BCs]
  [top_stress]
    type = Pressure
    variable = disp_y
    boundary = 't'
    function = 'vs_func' # pa
  []
  [bottom_stress]
    type = Pressure
    variable = disp_y
    boundary = 'b'
    function = 'vs_func' # pa
  []
  [right_stress]
    type = Pressure
    variable = disp_x
    boundary = 'r'
    function = 'hs_func' # pa
  []
  [left_stress]
    type = Pressure
    variable = disp_x
    boundary = 'l'
    function = 'hs_func' # pa
  []
  [CavityPressure_x]
    type = Pressure
    boundary = 'c'
    displacements = 'disp_x disp_y'
    variable = disp_x
    function = '${inner_pressure}' # pa
  []
  [CavityPressure_y]
    type = Pressure
    boundary = 'c'
    displacements = 'disp_x disp_y'
    variable = disp_y
    function = '${inner_pressure}' # pa
  []
  [2]
    type = DirichletBC
    value = 0
    boundary = 'mb'
    variable = 'disp_x'
  []
  [3]
    type = DirichletBC
    value = 0
    boundary = 'mt'
    variable = 'disp_x'
  []
  [6]
    type = DirichletBC
    value = 0
    boundary = 'ml'
    variable = 'disp_y'
  []
  [8]
    type = DirichletBC
    value = 0
    boundary = 'mr'
    variable = 'disp_y'
  []
[]

[ICs]
  [ic_ux]
    type = ConstantIC
    variable = disp_x
    value = 0.0
  []
  [ic_uy]
    type = ConstantIC
    variable = disp_y
    value = 0.0
  []
[]

[UserObjects]
  [coh_1]
    type = SolidMechanicsHardeningConstant
    value = '${coh_1}'
  []
  [phi_1] # By setting the dilation angle equal to friction angle, it will be easier problem to solve for MOOSE
    type = SolidMechanicsHardeningConstant
    value = '${phi_1}'
    convert_to_radians = true
  []
  [psi_1]
    type = SolidMechanicsHardeningConstant
    value = '${psi_1}' # Defines hardening of the dilation angle (in radians)
    convert_to_radians = true
  []
  [cs_1]
    type = SolidMechanicsHardeningPowerRule
    value_0 = '${compressive_strength_1}'
    exponent = 1.0
    epsilon0 = '${epsilon_1}'
  []
  [ts_1]
    type = SolidMechanicsHardeningPowerRule
    value_0 = '${compressive_strength_1}'
    exponent = 1.0
    epsilon0 = '${epsilon_1}'
  []
  [dp_1]
    type = SolidMechanicsPlasticDruckerPrager # Non-associative DruckerPrager plasticity with hardening/softening
    mc_cohesion = 'coh_1' # Cohesion
    mc_friction_angle = 'phi_1' # Internal friction angle
    mc_dilation_angle = 'psi_1' # Dilation angle
    yield_function_tolerance = '1E-8' # If the yield function is less than this amount, the (stress, internal parameter) are deemed admissible.
    internal_constraint_tolerance = '1E-4' # The Newton-Raphson process is only deemed converged if the internal constraint is less than this.
  []
  [coh_2]
    type = SolidMechanicsHardeningConstant
    value = '${coh_2}'
  []
  [phi_2]
    type = SolidMechanicsHardeningConstant
    value = '${phi_2}'
    convert_to_radians = true
  []
  [psi_2]
    type = SolidMechanicsHardeningConstant
    value = '${psi_2}'
    convert_to_radians = true
  []
  [cs_2]
    type = SolidMechanicsHardeningPowerRule
    value_0 = '${compressive_strength_2}'
    exponent = 1.0
    epsilon0 = '${epsilon_2}'
  []
  [ts_2]
    type = SolidMechanicsHardeningPowerRule
    value_0 = '${compressive_strength_2}'
    exponent = 1.0
    epsilon0 = '${epsilon_2}'
  []
  [dp_2]
    type = SolidMechanicsPlasticDruckerPrager
    # Non-associative DruckerPrager plasticity with hardening/softening
    mc_cohesion = 'coh_2' # Cohesion
    mc_friction_angle = 'phi_2' # Internal friction angle
    mc_dilation_angle = 'psi_2' # Dilation angle
    yield_function_tolerance = 1E-8 # If the yield function is less than this amount, the (stress, internal parameter) are deemed admissible.
    internal_constraint_tolerance = 1E-4 # The Newton-Raphson process is only deemed converged if the internal constraint is less than this.
  []
[]

[Materials]
  [elasticity_tensor_1]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${youngs_modulus_1}' # Pa
    poissons_ratio = '${poissons_ratio_1}'
    block = 'block1'
  []
  [dp_1]
    type = CappedDruckerPragerStressUpdate
    DP_model = 'dp_1'
    compressive_strength = 'cs_1'
    smoothing_tol = 1E-7
    tensile_strength = 'ts_1'
    tip_smoother = 8
    yield_function_tol = 1E-8
    block = 'block1'
  []
  [admissible_1]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'dp_1'
    block = 'block1'
    perform_finite_strain_rotations = false
  []
  [elasticity_tensor_2]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${youngs_modulus_2}' # Pa
    poissons_ratio = '${poissons_ratio_2}'
    block = 'block2'
  []
  [dp_2]
    type = CappedDruckerPragerStressUpdate
    DP_model = 'dp_2'
    compressive_strength = 'cs_2'
    smoothing_tol = 1E-7
    tensile_strength = 'ts_2'
    tip_smoother = 8
    yield_function_tol = 1E-8
    block = 'block2'
  []
  [admissible_2]
    type = ComputeMultipleInelasticStress
    inelastic_models = dp_2
    block = 'block2'
    perform_finite_strain_rotations = false
  []
[]

# [Preconditioning]
#   [SMP]
#     type = SMP
#     full = true
#   []
# []

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  end_time = 1
  dt = 0.5
  # petsc_options = '-snes_converged_reason'
  # petsc_options_iname = '-pc_type -ksp_type -ksp_gmres_restart'
  # petsc_options_value = ' bjacobi  gmres     200'

  # nl_abs_tol = 1e-3
  # nl_rel_tol = 1e-5

  # l_max_its = 10000
  # nl_max_its = 10000
[]

[Outputs]
  [out]
    type = Exodus
    # file_base = '../../elasticity_output/homogenous/1'
  []
[]

# Mohr-Coulomb: 'materials/CappedMohrCoulombStressUpdate' or 'userobjects/SolidMechanicsPlasticMohrCoulomb'
# Drucker-Prager: materials: CappedDruckerPragerStressUpdate, CappedDruckerPragerCosseratStressUpdate
# userobjects: TensorMechanicsPlasticDruckerPrager, SolidMechanicsPlasticDruckerPrager
# https://github.com/idaholab/moose/discussions/17613 explain for solid mechanics hardening parameters
