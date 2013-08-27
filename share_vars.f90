! Variables for pseudospectral simnulations
module vars
  use mpi_header
  implicit none

  character*1,save:: tab ! Fortran lacks a native tab, so we set one up.

  ! Precision of doubles
  integer,parameter :: pr = 8 

  ! Method variables set in the program file:
  character(len=3),save:: method ! mhd  or fsi
  integer,save :: nf ! number of fields (1 for NS, 2 for MHD)
  integer,save :: nd ! number of fields (3 for NS, 6 for MHD)

  ! MPI and p3dfft variables and parameters
  integer,save :: mpisize,mpirank,mpicommcart
  integer,parameter :: mpiinteger=MPI_INTEGER
  integer,parameter :: mpireal=MPI_DOUBLE_PRECISION
  integer,parameter :: mpicomplex=MPI_DOUBLE_COMPLEX
  integer,dimension(2),save :: mpidims,mpicoords,mpicommslab
  integer,dimension (:,:),allocatable,save :: ra_table,rb_table
  ! Local array bounds
  integer,dimension (1:3),save :: ra,rb,rs,ca,cb,cs

  ! Used in params.f90
  integer,parameter :: nlines=2048 ! maximum number of lines in PARAMS-file

  real(kind=pr),save :: pi ! 3.14....

  real (kind=pr),dimension(:),allocatable,save :: lin ! contains nu and eta

  ! Vabiables timing statistics.  Global to simplify syntax.
  real (kind=pr),save :: time_fft,time_ifft,time_vis,time_mask,time_fft2
  real (kind=pr),save :: time_vor,time_curl,time_p,time_nlk,time_u, time_ifft2
  real (kind=pr),save :: time_bckp,time_save,time_total,time_fluid,time_nlk_fft

  ! The mask array.  TODO: move out of shave_vars?
  real (kind=pr),dimension (:,:,:),allocatable,save :: mask ! mask function
  ! Velocity field inside the solid.  TODO: move out of shave_vars?
  real (kind=pr),allocatable,save :: us(:,:,:,:)  ! Velocity in solid


  ! Variables set via the parameters file
  real(kind=pr),save :: length ! FIXME: what is length?
  ! Domain size variables:
  integer,save :: nx,ny,nz
  real(kind=pr),save :: xl,yl,zl,dx,dy,dz,scalex,scaley,scalez

  ! FIXME: please document
  integer,save :: iDealias,iKinDiss

  ! Parameters to set which files are saved and how often:
  integer,save :: iSaveVelocity,iSaveVorticity,iSavePress,iSaveMask
  integer,save :: iDoBackup
  real(kind=pr),save :: tintegral ! Time between output of integral quantities
  real(kind=pr),save :: tsave ! Time between outpout of entire fields.
  integer,save :: itdrag

  ! Time-stepping parameters
  real(kind=pr),save :: tmax
  real(kind=pr),save :: tstart
  real(kind=pr),save :: cfl
  integer,save :: nt
  character(len=80),save :: iTimeMethodFluid

  ! Physical parameters:
  real(kind=pr),save :: nu

  ! Initial conditions:
  character(len=80),save :: inicond
  real(kind=pr),save :: omega1

  ! Boundary conditions:
  character(len=80),save :: iMask
  integer,save :: iMoving,iPenalization
  real(kind=pr),save :: dt_fixed
  real(kind=pr),save :: eps
  real(kind=pr),save :: r1,r2,r3 ! Parameters for boundary conditions
end module vars


! Variables for fsi simulations
module fsi_vars
  use vars
  implicit none

  real (kind=pr),save :: x0,y0,z0 ! Parameters for logical centre of obstacle
  real(kind=pr),save :: Ux,Uy,Uz
  integer,save :: iMeanFlow
  integer,save :: iDrag
  integer,save :: iSaveSolidVelocity

  ! The derived integral quantities for fluid-structure interactions.
  type Integrals
     real(kind=pr) :: time
     real(kind=pr) :: EKin
     real(kind=pr) :: Dissip
     real(kind=pr) :: Divergence
     real(kind=pr) :: Volume
     real(kind=pr),dimension(1:3) :: Force
  end type Integrals

  type(Integrals),save :: GlobalIntegrals
end module fsi_vars


! Variables for mhd simulations
module mhd_vars
  use vars
  implicit none

  ! Physical parameters
  real(kind=pr),save :: eta ! magnetic diffusivity
  real(kind=pr),save :: b0, bc ! Boundary condition parameters

  ! Determine whether we save various fields
  integer,save :: iSaveMagneticField,iSaveCurrent
end module mhd_vars


! Compute the FFT of the real-valued 3D array inx and save the output
! in the complex-valued 3D array outk.
subroutine fft(outk,inx)
    use mpi_header
    use vars ! For precision specficiation and array sizes
    
    real(kind=pr),intent(in)::inx(ra(1):rb(1),ra(2):rb(2),ra(3):rb(3))
    complex(kind=pr),intent(out)::outk(ca(1):cb(1),ca(2):cb(2),ca(3):cb(3))

    call coftxyz(inx,outk)
end subroutine fft


! Compute the inverse FFT of the complex-valued 3D array ink and save the
! output in the real-valued 3D array outx.
subroutine ifft(outx,ink)
    use mpi_header
    use vars ! For precision specficiation and array sizes
    
    complex(kind=pr),intent(in)::ink(ca(1):cb(1),ca(2):cb(2),ca(3):cb(3))
    real(kind=pr),intent(out)::outx(ra(1):rb(1),ra(2):rb(2),ra(3):rb(3))

    call cofitxyz(ink,outx)
end subroutine ifft
