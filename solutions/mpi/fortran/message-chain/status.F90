program basic
  use mpi
  use iso_fortran_env, only : REAL64

  implicit none
  integer, parameter :: size = 10000000
  integer :: rc, myid, ntasks
  integer :: message(size)
  integer :: receiveBuffer(size)
  integer :: status(MPI_STATUS_SIZE)

  real(REAL64) :: t0, t1 

  integer :: source, destination
  integer :: count

  call mpi_init(rc)
  call mpi_comm_rank(MPI_COMM_WORLD, myid, rc)
  call mpi_comm_size(MPI_COMM_WORLD, ntasks, rc)

  message = myid

  ! Set source and destination ranks
  if (myid < ntasks-1) then
     destination = myid + 1
  else
     destination = MPI_PROC_NULL
  end if
  if (myid > 0) then
     source = myid - 1
  else
     source = MPI_PROC_NULL
  end if

  call mpi_barrier(mpi_comm_world, rc)
  t0 = mpi_wtime()

  ! Send and receive messages
  call mpi_sendrecv(message, size, MPI_INTEGER, destination, myid + 1, &
       receiveBuffer, size, MPI_INTEGER, source, MPI_ANY_TAG, &
       MPI_COMM_WORLD, status, rc)
  ! Use status parameter to find out the no. of elements received
  call mpi_get_count(status, MPI_INTEGER, count, rc)
  write(*,'(A10,I3,A20,I8,A,I3,A,I3)') 'Sender: ', myid, &
       ' Sent elements: ', size, &
       '. Tag: ', myid + 1, &
       '. Receiver: ', destination
  write(*,'(A10,I3,A20,I8,A,I3,A,I3)') 'Receiver: ', myid, &
       ' Received elements: ', count, &
       '. Tag: ', status(MPI_TAG), &
       '. Sender: ', status(MPI_SOURCE)

  t1 = mpi_wtime()
  call mpi_barrier(mpi_comm_world, rc)
  call flush(6)

  write(*, '(A20, I3, A, F6.3)') 'Time elapsed in rank', myid, ':', t1-t0

  call mpi_finalize(rc)
end program basic
