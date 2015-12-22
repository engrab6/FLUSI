!-------------------------------------------------------------------------------
! Stroke plane
! Input:
!       time
! Output:
!       eta_stroke: stroke plane angle
subroutine StrokePlane ( time, Insect )
  use vars
  implicit none

  real(kind=pr), intent(in) :: time
  type(diptera), intent(inout) :: Insect
  real(kind=pr) :: eta_stroke
  character(len=strlen) :: dummy

  select case (Insect%BodyMotion)
  case ("free_flight")
    eta_stroke = Insect%eta0  ! read from file
  case ("tethered")
    eta_stroke = Insect%eta0  ! read from file
  case ("command-line")
    call get_command_argument(16,dummy)
    read (dummy,*) eta_stroke

    if(root) write(*,'("eta=",g12.4,"°")') eta_stroke
    eta_stroke = deg2rad(eta_stroke)

  case ("takeoff")
    eta_stroke = Insect%eta_stroke ! read from file
  case default
    if (mpirank==0) then
    write (*,*) "insects.f90::StrokePlane: motion case (Insect%BodyMotion) undefined"
    call abort()
    endif
  end select

  ! save it in the insect
  Insect%eta_stroke = eta_stroke

end subroutine StrokePlane
