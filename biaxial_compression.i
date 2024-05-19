[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 5
  ny = 5
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]
[Kernels]
  [./TensorMechanics]
    strain = SMALL
    displacements = 'disp_x disp_y'
    add_variables = true
    out_of_plane_direction = z
    planar_formulation = PLANE_STRAIN
    #eigenstrain_names = 'eigenstrain'
    generate_output = 'plastic_strain_yy'
  [../]
[]
[BCs]
  [./Xmin]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
  [../]
  [./Xmax]
    type = NeumannBC
    boundary = top
    variable = disp_x
    value = -1
    use_displaced_mesh = false
  [../]
   [./Ymin]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  [../]
  [./Ymax]
    type = NeumannBC
    boundary = top
    variable = disp_y
    value = -10
    use_displaced_mesh = false
  [../]
[]
[AuxVariables]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mc_int]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./yield_fcn]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
  [./mc_int_auxk]
    type = MaterialStdVectorAux
    index = 0
    property = plastic_internal_parameter
    variable = mc_int
  [../]
  [./yield_fcn_auxk]
    type = MaterialStdVectorAux
    index = 0
    property = plastic_yield_function
    variable = yield_fcn
  [../]
[]

[Postprocessors]
  [./s_xx]
    type = PointValue
    point = '0 0 0'
    variable = stress_xx
  [../]
  [./s_xy]
    type = PointValue
    point = '0 0 0'
    variable = stress_xy
  [../]
  [./s_yy]
    type = PointValue
    point = '0 0 0'
    variable = stress_yy
  [../]
  [./internal]
    type = PointValue
    point = '0 0 0'
    variable = mc_int
  [../]
  [./f]
    type = PointValue
    point = '0 0 0'
    variable = yield_fcn
  [../]
[]

[UserObjects]
  [./mc_coh]
    type = TensorMechanicsHardeningConstant
    value = 1   #1kN/m2
  [../]
   [./mc_phi]
    type = TensorMechanicsHardeningConstant
    value = 30    # 30 degree
    convert_to_radians = true
  [../]
  [./mc_psi]
    type = TensorMechanicsHardeningConstant
    value = 0.01
    convert_to_radians = true
  [../]
  [./mc]
    type = TensorMechanicsPlasticMohrCoulomb
    cohesion = mc_coh
    friction_angle = mc_phi
    dilation_angle = mc_psi
    mc_tip_smoother = 10
    mc_edge_smoother = 25
    yield_function_tolerance = 1E-3
    internal_constraint_tolerance = 1E-9
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1000   # 1000 kN/m2
    poissons_ratio = 0.25
  [../]

  [./strain]
    type = ComputeFiniteStrain
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./mc]
    type = ComputeMultiPlasticityStress
    block = 0
    ep_plastic_tolerance = 1E-9
    plastic_models = mc
    debug_fspb = crash
    debug_jac_at_stress = '10 1 2 1 10 3 2 3 10'
    debug_jac_at_pm = 1
    debug_jac_at_intnl = 1E-3
    debug_stress_change = 1E-5
    debug_pm_change = 1E-6
    debug_intnl_change = 1E-6
  [../]
[]

[Executioner]
  end_time = 1
  dt = 0.1
  type = Transient

  # controls for linear iterations
    l_max_its = 100
    l_tol = 1e-5

  # controls for nonlinear iterations
    nl_max_its = 10
    nl_rel_tol = 1e-5
[]

[Outputs]
  file_base = small_deform_hard2
  exodus = true
  [./csv]
    type = CSV
    [../]
[]
