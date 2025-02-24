C
C  /* Deck so_gett2 */
      SUBROUTINE SO_GETT2(KEY,T2AM,LT2AM,DENSAI,LDENSAI,DENSIJ,
     &                    LDENSIJ,DENSAB,LDENSAB,WORK,LWORK)
C
C     This routine is part of the atomic integral direct SOPPA program.
C
C     Keld Bak, December 1997
C     Stephan P. A. Sauer, November 2003: merge with DALTON 2.0
C
C     PURPOSE: Get the appropriate T2 and possibly T1 amplitudes
C              for RPA(D), SOPPA and SOPPA(CCSD) and calculate
C              the corresponding densities.
C
#include "implicit.h"
#include "priunit.h"
C
#include "soppinf.h"
C
      PARAMETER (HALF = 0.5D0,ESUDIP = 64604.885D0,ESUECD = 471.44360D0)
C
C      CHARACTER KEY*4, FNAME*8
      CHARACTER KEY*4
c      LOGICAL   OPNSTA
      DIMENSION T2AM(LT2AM), DENSAI(LDENSAI)
      DIMENSION DENSIJ(LDENSIJ), DENSAB(LDENSAB)
      DIMENSION WORK(LWORK)
C
C------------------
C     Add to trace.
C------------------
C
      CALL QENTER('SO_GETT2')
CPi-150316
C--------------------------------------------
C     If Triplet T2AM will get double length
C--------------------------------------------
C
      LT2AMH = LT2AM
      IF (TRIPLET) LT2AMH = INT(LT2AM/2)
Cend-Pi
      IF ( KEY(1:3) .EQ. 'MP2' ) THEN
C
C-----------------------------------------
C        Read MP2 T2-amplitudes from disk.
C-----------------------------------------
C
         LUTAM = -1
         CALL GPOPEN(LUTAM,'MP2__TAM','OLD',' ','UNFORMATTED',IDUMMY,
     &               .FALSE.)
         REWIND LUTAM
C
         READ(LUTAM)
CPi-150316
C         READ(LUTAM) (T2AM(I), I = 1,LT2AM)
         READ(LUTAM) (T2AM(I), I = 1,LT2AMH)
Cend-Pi
         CALL GPCLOSE(LUTAM,'KEEP')
CPi 11.08.16: Add CC2
      ELSE IF ( KEY(1:3) .EQ. 'CC2' ) THEN
C
C--------------------------------------------------
C        Read CC2 T1- and T2-amplitudes from disk.
C--------------------------------------------------
C
         LUTAM = -1
         CALL GPOPEN(LUTAM,'CC2__TAM','OLD',' ','UNFORMATTED',IDUMMY,
     &               .FALSE.)
         REWIND LUTAM
C
         READ(LUTAM) (DENSAI(I), I = 1,LDENSAI)
         CALL DSCAL(LDENSAI,HALF,DENSAI,1)
CPi-150316
C         READ(LUTAM) (T2AM(I), I = 1,LT2AM)
         READ(LUTAM) (T2AM(I), I = 1,LT2AMH)
Cend-Pi
         CALL GPCLOSE(LUTAM,'KEEP')
Cend-Pi
      ELSE IF ( KEY(1:4) .EQ. 'CCSD' ) THEN
C
C--------------------------------------------------
C        Read CCSD T1- and T2-amplitudes from disk.
C--------------------------------------------------
C
         LUTAM = -1
         CALL GPOPEN(LUTAM,'CCSD_TAM','OLD',' ','UNFORMATTED',IDUMMY,
     &               .FALSE.)
         REWIND LUTAM
C
         READ(LUTAM) (DENSAI(I), I = 1,LDENSAI)
         CALL DSCAL(LDENSAI,HALF,DENSAI,1)
CPi-150316
C         READ(LUTAM) (T2AM(I), I = 1,LT2AM)
         READ(LUTAM) (T2AM(I), I = 1,LT2AMH)
Cend-Pi
         CALL GPCLOSE(LUTAM,'KEEP')

      END IF
C
C----------------------------------------------------
C     Calculate the density matrices D(ij) and D(ab).
C----------------------------------------------------
C
      DTIME     = SECOND()
CPi-150316
C      CALL SO_DENS(DENSIJ,LDENSIJ,DENSAB,LDENSAB,
C     &             T2AM,LT2AM,WORK,LWORK)
      CALL SO_DENS(DENSIJ,LDENSIJ,DENSAB,LDENSAB,
     &             T2AM,LT2AMH,WORK,LWORK)
Cend-Pi
      DTIME     = SECOND()  - DTIME
      SOTIME(4) = SOTIME(4) + DTIME
C
C------------------------------------------------------
C     Replace T2-amplitudes in T2AM with MP2-amplitudes
C     (2 * coulomb - exchange of T2-amplitudes).
C------------------------------------------------------
C
      DTIME     = SECOND()
CPi-150316
C Using LT2AMH here and do not initialize LT2MPH in so_t2mp
Cend-Pi
      CALL SO_T2MP(T2AM,LT2AMH)
      DTIME     = SECOND()  - DTIME
      SOTIME(5) = SOTIME(5) + DTIME
C
C-----------------------
C     Remove from trace.
C-----------------------
C
      CALL QEXIT('SO_GETT2')
C
      RETURN
      END
