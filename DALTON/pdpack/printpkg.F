C FILE    : printpkg.F
C
C...   Dalton, pdpack/printpkg.F
C...
C...   These routines are in the public domain and can be
C...   used freely in other programs.
C...
C
C FILE: printpkg.F
C
C ====================================================================================
C For all OUT* routines, the NCTL parameter is used to select different output formats.
C ------------------------------------------------------------------------------------
C     NCTL > 0: fit in 80 columns
C     NCTL < 0: fit in 132 columns
C     abs(NCTL) .ge. 10: also print zero rows
C     abs(NCTL) =2 or =3: write old obsolete line printer carriage control characters
C               for double or triple space between lines
C ====================================================================================
C
C  /* Deck outpak */
      SUBROUTINE OUTPAK (AMATRX,NROW,NCTL,LUPRI)
C.......................................................................
C Revised 16-Dec-1983 by Hans Jorgen Aa. Jensen.
C         16-Jun-1986 hjaaj ( removed Hollerith )
C
C OUTPAK PRINTS A REAL SYMMETRIC MATRIX STORED IN ROW-PACKED LOWER
C
C TRIANGULAR FORM (SEE DIAGRAM BELOW) IN FORMATTED FORM WITH NUMBERED
C
C ROWS AND COLUMNS.  THE INPUT IS AS FOLLOWS:
C
C        AMATRX(*)...........PACKED MATRIX
C
C        NROW................NUMBER OF ROWS TO BE OUTPUT
C
C        NCTL................CARRIAGE CONTROL FLAG: 1 FOR SINGLE SPACE,
C                                                   2 FOR DOUBLE SPACE,
C                                                   3 FOR TRIPLE SPACE.
C
C THE MATRIX ELEMENTS ARE ARRANGED IN STORAGE AS FOLLOWS:
C
C        1
C        2    3
C        4    5    6
C        7    8    9   10
C       11   12   13   14   15
C       16   17   18   19   20   21
C       22   23   24   25   26   27   28
C       AND SO ON.
C
C OUTPAK IS SET UP TO HANDLE 6 COLUMNS/PAGE WITH A 6F20.14 FORMAT
C FOR THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED, CHANGE
C FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER OF
C COLUMNS.
C
C AUTHOR:  NELSON H.F. BEEBE, QUANTUM THEORY PROJECT, UNIVERSITY OF
C          FLORIDA, GAINESVILLE
C..........VERSION = 09/05/73/03
C.......................................................................
C
#include "implicit.h"
      DIMENSION AMATRX(*)
      INTEGER BEGIN
      CHARACTER*1 ASA(3),BLANK,CTL
      CHARACTER   PFMT*20, COLUMN*8
      PARAMETER (ZERO=0.D00, KCOLP=4, KCOLN=6)
      PARAMETER (FFMIN=1.D-3, FFMAX = 1.D3)
      LOGICAL IS_NAN
      DATA COLUMN/'Column  '/, ASA/' ', '0', '-'/, BLANK/' '/
C
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      J = NROW*(NROW+1)/2
      AMAX = ZERO
      BMAX = ZERO
      CMAX = ZERO
      N_NAN = 0
      DO I = 1,J
         IF (IS_NAN(AMATRX(I),AMATRX(I))) THEN
            N_NAN = N_NAN + 1
         ELSE
            AMAX = MAX( AMAX, ABS(AMATRX(I)) )
            BMAX = MAX( BMAX, AMATRX(I))
            CMAX = MIN( CMAX, AMATRX(I))
         END IF
      END DO
      IF (N_NAN .GT. 0) WRITE (LUPRI,'(/T6,A,I10,A)')
     &   'WARNING: matrix contains',N_NAN,' NaN.'
      IF (AMAX .EQ. ZERO) THEN
         WRITE (LUPRI,'(/T6,A)') 'Zero matrix.'
         GO TO 200
      END IF
      IF (FFMIN .LE. AMAX .AND. AMAX .LE. FFMAX) THEN
C        use F output format
         PFMT = '(A1,I7,2X,8F15.8)'
      ELSE
C        use 1PD output format
         PFMT = '(A1,I7,2X,1P,8E15.6)'
      END IF
C
C LAST IS THE LAST COLUMN NUMBER IN THE ROW CURRENTLY BEING PRINTED
C
      LAST = MIN(NROW,KCOL)
C
C BEGIN IS THE FIRST COLUMN NUMBER IN THE ROW CURRENTLY BEING PRINTED.
C
C.....BEGIN NON STANDARD DO LOOP.
      BEGIN= 1
 1050 NCOL = 1
         WRITE (LUPRI,1000) (COLUMN,I,I = BEGIN,LAST)
         DO 40 K = BEGIN,NROW
            KTOTAL = (K*(K-1))/2 + BEGIN - 1
            IF (MCTL .GE. 10) GO TO 20 ! also print zero rows
            DO 10 I = 1,NCOL
               IF (AMATRX(KTOTAL+I) .NE. ZERO) GO TO 20
   10       CONTINUE
            GO TO 30
   20       WRITE (LUPRI,PFMT) CTL,K,(AMATRX(J+KTOTAL),J=1,NCOL)
   30       IF (K .LT. (BEGIN+KCOL-1)) NCOL = NCOL + 1
   40    CONTINUE
         LAST = MIN(LAST+KCOL,NROW)
         BEGIN= BEGIN + NCOL
      IF (BEGIN.LE.NROW) GO TO 1050
  200 CONTINUE
      WRITE(LUPRI,'(A)') '    ==== End of matrix output ===='
      RETURN
C
 1000 FORMAT (/10X,8(5X,A6,I4))
      END
C  /* Deck outpkb */
      SUBROUTINE OUTPKB (AMATRX,NDIM,NBLK,NCTL,LUPRI)
C.......................................................................
C
C OUTPKB is OUTPAK modified for blocking as specified by
C        NDIM(NBLK).  16-Dec-1983 Hans Jorgen Aa. Jensen.
C
C 16-Jun-1986 hjaaj ( removed Hollerith )
C
C OUTPAK PRINTS A REAL OMSYMMETRIC MATRIX STORED IN ROW-PACKED LOWER
C TRIANGULAR FORM (SEE DIAGRAM BELOW) IN FORMATTED FORM WITH NUMBERED
C ROWS AND COLUMNS.  THE INPUT IS AS FOLLOWS:
C
C        AMATRX(')...........PACKED MATRIX, blocked
C
C        NDIM(').............dimension of each block
C
C        NBLK................number of blocks
C
C        NCTL................CARRIAGE CONTROL FLAG: 1 FOR SINGLE SPACE,
C                                                   2 FOR DOUBLE SPACE,
C                                                   3 FOR TRIPLE SPACE.
C
C THE MATRIX ELEMENTS in a block ARE ARRANGED IN STORAGE AS
C FOLLOWS:
C
C        1
C        2    3
C        4    5    6
C        7    8    9   10
C       11   12   13   14   15
C       16   17   18   19   20   21
C       22   23   24   25   26   27   28
C       AND SO ON.
C
C OUTPAK IS SET UP TO HANDLE 6 COLUMNS/PAGE WITH A 6F20.14 FORMAT
C FOR THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED, CHANGE
C FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER OF
C COLUMNS.
C
C AUTHOR:  NELSON H.F. BEEBE, QUANTUM THEORY PROJECT, UNIVERSITY OF
C          FLORIDA, GAINESVILLE
C..........OUTPAK VERSION = 09/05/73/03
C.......................................................................
C
#include "implicit.h"
      INTEGER NDIM(NBLK),BEGIN
      DIMENSION AMATRX(*)
      CHARACTER*1 ASA(3),BLANK,CTL
      CHARACTER   PFMT*20, COLUMN*8
      LOGICAL     IS_NAN
      PARAMETER (ZERO = 0.0D0, KCOLP=4, KCOLN=6)
      PARAMETER (FFMIN=1.D-3, FFMAX = 1.D3)
      DATA COLUMN/'Column  '/, ASA/' ', '0', '-'/, BLANK/' '/
C
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      MATLN = 0
      DO 200 IBLK = 1,NBLK
         MATLN = MATLN + NDIM(IBLK)*(NDIM(IBLK)+1)/2
  200 CONTINUE
C
      AMAX = ZERO
      N_NAN = 0
      DO I=1,MATLN
         IF ( IS_NAN(AMATRX(I),AMATRX(I)) ) THEN
            N_NAN = N_NAN + 1
         ELSE
            AMAX = MAX( AMAX, ABS(AMATRX(I)) )
         END IF
      END DO
      IF (N_NAN .GT. 0) WRITE (LUPRI,'(/T6,A,I10,A)')
     &   'WARNING: matrix contains',N_NAN,' NaN.'
      IF (AMAX .EQ. ZERO) THEN
         WRITE (LUPRI,3000) NBLK
         GO TO 800
      END IF
      IF (FFMIN .LE. AMAX .AND. AMAX .LE. FFMAX) THEN
C        use F output format
         PFMT = '(A1,I7,2X,8F15.8)'
      ELSE
C        use 1PD output format
         PFMT = '(A1,I7,2X,1P,8D15.6)'
      END IF
C
      IOFF = 0
      DO 100 IBLK = 1,NBLK
         IDIM = NDIM(IBLK)
      IF (IDIM.EQ.0) GO TO 100
         IIDIM = IDIM*(IDIM+1)/2
C
         DO 5 I=1,IIDIM
            IF (AMATRX(IOFF+I).NE.ZERO) GO TO 15
    5    CONTINUE
         WRITE (LUPRI,1100) IBLK
         GO TO 90
   15    CONTINUE
         WRITE (LUPRI,1200) IBLK
C
C LAST IS THE LAST COLUMN NUMBER IN THE ROW CURRENTLY BEING PRINTED
C
         LAST = MIN(IDIM,KCOL)
C
C BEGIN IS THE FIRST COLUMN NUMBER IN THE ROW CURRENTLY BEING PRINTED.
C
         BEGIN = 1
C.....BEGIN NON STANDARD DO LOOP.
 1050       NCOL = 1
            WRITE (LUPRI,1000) (COLUMN,I,I = BEGIN,LAST)
            KTOTAL = IOFF + BEGIN*(BEGIN+1)/2 - 1
            DO 40 K = BEGIN,IDIM
               IF (MCTL .GE. 10) GO TO 20 ! also print zero rows
               DO 10 I = 1,NCOL
                  IF (AMATRX(KTOTAL+I) .NE. ZERO) GO TO 20
   10          CONTINUE
               GO TO 30
   20          WRITE (LUPRI,PFMT) CTL,K,(AMATRX(KTOTAL+J),J=1,NCOL)
   30          IF (K .LT. (BEGIN+KCOL-1)) NCOL = NCOL + 1
               KTOTAL = KTOTAL + K
   40       CONTINUE
            LAST = MIN(LAST+KCOL,IDIM)
            BEGIN=BEGIN+NCOL
         IF (BEGIN.LE.IDIM) GO TO 1050
C
   90    IOFF = IOFF + IIDIM
  100 CONTINUE
C
  800 CONTINUE
      WRITE(LUPRI,'(A)') '    ==== End of matrix output ===='
      RETURN
 3000 FORMAT (/5X,'All',I3,' blocks zero matrices.')
 1100 FORMAT (/5X,'*** Block',I3,' zero matrix. ***')
 1200 FORMAT (/5X,'*** Block',I3,' ***')
 1000 FORMAT (/10X,8(5X,A6,I4))
      END
C  /* Deck outpks */
      SUBROUTINE OUTPKS (AMATRX,NDIM,NBLK,IREPO,NCTL,LUPRI)
C.......................................................................
C
C OUTPKS is OUTPAK modified for blocking as specified by
C        NDIM(NBLK).  16-Dec-1983 Hans Jorgen Aa. Jensen.
C        14-Dec-1988 tuh , accepts not totally symmetric elements
C
C 16-Jun-1986 hjaaj ( removed Hollerith )
C
C OUTPAK PRINTS A REAL OMSYMMETRIC MATRIX STORED IN ROW-PACKED LOWER
C TRIANGULAR FORM (SEE DIAGRAM BELOW) IN FORMATTED FORM WITH NUMBERED
C ROWS AND COLUMNS.  THE INPUT IS AS FOLLOWS:
C
C        AMATRX(')...........PACKED MATRIX, blocked
C
C        NDIM(').............dimension of each block
C
C        NBLK................number of blocks
C
C        NCTL................CARRIAGE CONTROL FLAG: 1 FOR SINGLE SPACE,
C                                                   2 FOR DOUBLE SPACE,
C                                                   3 FOR TRIPLE SPACE.
C
C THE MATRIX ELEMENTS in a block ARE ARRANGED IN STORAGE AS
C FOLLOWS:
C
C        1
C        2    3
C        4    5    6
C        7    8    9   10
C       11   12   13   14   15
C       16   17   18   19   20   21
C       22   23   24   25   26   27   28
C       AND SO ON.
C
C OUTPAK IS SET UP TO HANDLE 6 COLUMNS/PAGE WITH A 6F20.14 FORMAT
C FOR THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED, CHANGE
C FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER OF
C COLUMNS.
C
C AUTHOR:  NELSON H.F. BEEBE, QUANTUM THEORY PROJECT, UNIVERSITY OF
C          FLORIDA, GAINESVILLE
C..........OUTPAK VERSION = 09/05/73/03
C.......................................................................
C
#include "implicit.h"
      INTEGER NDIM(NBLK),BEGIN
      DIMENSION AMATRX(*)
      CHARACTER*1 ASA(3),BLANK,CTL
      CHARACTER   PFMT*20, COLUMN*8
      PARAMETER (D0 = 0.0D0, KCOLP=4, KCOLN=6)
      PARAMETER (FFMIN=1.D-3, FFMAX = 1.D3)
      DATA COLUMN/'Column  '/, ASA/' ', '0', '-'/, BLANK/' '/

C
      IF (IREPO .NE. 1) THEN
         IBLK = 1
         DO 500 IREPB = 0, NBLK - 1
            IREPA = IEOR(IREPO - 1,IREPB)
            IF (IREPA .GT. IREPB) THEN
               NDIMA = NDIM(IREPA + 1)
               NDIMB = NDIM(IREPB + 1)
               WRITE (LUPRI,'(/A,2I5)') ' Symmetries: ',IREPA+1,IREPB+1
               WRITE (LUPRI,'(/A,2I5)') ' Dimensions: ',NDIMA,NDIMB
               IF (NDIMA.GT.0 .AND. NDIMB.GT.0) THEN
                  CALL OUTPUT(AMATRX(IBLK),1,NDIMA,1,NDIMB,
     *                        NDIMA,NDIMB,NCTL,LUPRI)
                  IBLK = IBLK + NDIMA*NDIMB
               END IF
            ENDIF
 500     CONTINUE
         GO TO 800
      END IF
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      MATLN = 0
      DO 200 IBLK = 1,NBLK
         MATLN = MATLN + NDIM(IBLK)*(NDIM(IBLK)+1)/2
  200 CONTINUE
C
      AMAX = D0
      DO 205 I=1,MATLN
         AMAX = MAX( AMAX, ABS(AMATRX(I)) )
  205 CONTINUE
      IF (AMAX .EQ. D0) THEN
         WRITE (LUPRI,3000) NBLK
         GO TO 800
      END IF
      IF (FFMIN .LE. AMAX .AND. AMAX .LE. FFMAX) THEN
C        use F output format
         PFMT = '(A1,I7,2X,8F15.8)'
      ELSE
C        use 1PD output format
         PFMT = '(A1,I7,2X,1P,8D15.6)'
      END IF
C
      IOFF = 0
      DO 100 IBLK = 1,NBLK
         IDIM = NDIM(IBLK)
      IF (IDIM.EQ.0) GO TO 100
         IIDIM = IDIM*(IDIM+1)/2
C
         DO 5 I=1,IIDIM
            IF (AMATRX(IOFF+I).NE.D0) GO TO 15
    5    CONTINUE
         WRITE (LUPRI,1100) IBLK
         GO TO 90
   15    CONTINUE
         WRITE (LUPRI,1200) IBLK
C
C LAST IS THE LAST COLUMN NUMBER IN THE ROW CURRENTLY BEING PRINTED
C
         LAST = MIN(IDIM,KCOL)
C
C BEGIN IS THE FIRST COLUMN NUMBER IN THE ROW CURRENTLY BEING PRINTED.
C
         BEGIN = 1
C.....BEGIN NON STANDARD DO LOOP.
 1050       NCOL = 1
            WRITE (LUPRI,1000) (COLUMN,I,I = BEGIN,LAST)
            KTOTAL = IOFF + BEGIN*(BEGIN+1)/2 - 1
            DO 40 K = BEGIN,IDIM
               IF (MCTL .GE. 10) GO TO 20 ! also print zero rows
               DO 10 I = 1,NCOL
                  IF (AMATRX(KTOTAL+I) .NE. D0) GO TO 20
   10          CONTINUE
               GO TO 30
   20          WRITE (LUPRI,PFMT) CTL,K,(AMATRX(KTOTAL+J),J=1,NCOL)
   30          IF (K .LT. (BEGIN+KCOL-1)) NCOL = NCOL + 1
               KTOTAL = KTOTAL + K
   40       CONTINUE
            LAST = MIN(LAST+KCOL,IDIM)
            BEGIN=BEGIN+NCOL
         IF (BEGIN.LE.IDIM) GO TO 1050
C
   90    IOFF = IOFF + IIDIM
  100 CONTINUE
C
  800 CONTINUE
      WRITE(LUPRI,'(A)') '    ==== End of matrix output ===='
      RETURN
 3000 FORMAT (/5X,'All',I3,' blocks zero matrices.')
 1100 FORMAT (/5X,'*** Block',I3,' zero matrix. ***')
 1200 FORMAT (/5X,'*** Block',I3,' ***')
 1000 FORMAT (/10X,8(5X,A6,I4))
      END
C  /* Deck outptb */
      SUBROUTINE OUTPTB (AMATRX,NDIM,NBLK,NCTL,LUPRI)
C.......................................................................
C
C OUTPTB is OUTPUT modified for blocking as specified by
C        NDIM(NBLK).  16-Dec-1983 Hans Jorgen Aa. Jensen.
C
C 16-Jun-1986 hjaaj ( removed Hollerith )
C
C OUTPUT PRINTS A REAL MATRIX IN FORMATTED FORM WITH NUMBERED ROWS
C AND COLUMNS.  THE INPUT IS AS FOLLOWS;
C
C        AMATRX(',').........MATRIX TO BE OUTPUT, blocked
C
C        NDIM(').............dimension of each block
C
C        NBLK................number of blocks
C
C        NCTL................CARRIAGE CONTROL FLAG; 1 FOR SINGLE SPACE
C                                                   2 FOR DOUBLE SPACE
C                                                   3 FOR TRIPLE SPACE
C
C THE PARAMETERS THAT FOLLOW MATRIX ARE ALL OF TYPE INTEGER.  THE
C PROGRAM IS SET UP TO HANDLE 5 COLUMNS/PAGE WITH A 1P,5D24.15 FORMAT
C FOR 1THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED,
C CHANGE FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER
C OF COLUMNS.
C
C AUTHOR;  NELSON H.F. BEEBE, QUANTUM THEORY PROJECT, UNIVERSITY OF
C          FLORIDA, GAINESVILLE
C REVISED; FEBRUARY 26, 1971
C
C.......................................................................
C
#include "implicit.h"
      DIMENSION AMATRX(*)
      INTEGER NDIM(NBLK), BEGIN, KCOL
      CHARACTER*1 ASA(3), BLANK, CTL
      CHARACTER   PFMT*20, COLUMN*8
      LOGICAL     IS_NAN
      PARAMETER (ZERO=0.D00, KCOLP=4, KCOLN=6)
      PARAMETER (FFMIN=1.D-3, FFMAX = 1.D3)
      DATA COLUMN/'Column  '/, ASA/' ', '0', '-'/, BLANK/' '/
C
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      MATDIM = 0
      DO 200 IBLK = 1,NBLK
         MATDIM = MATDIM + NDIM(IBLK)*NDIM(IBLK)
  200 CONTINUE
C
      AMAX = ZERO
      N_NAN = 0
      DO I=1,MATDIM
         IF ( IS_NAN(AMATRX(I),AMATRX(I)) ) THEN
            N_NAN = N_NAN + 1
         ELSE
            AMAX = MAX( AMAX, ABS(AMATRX(I)) )
         END IF
      END DO
      IF (N_NAN .GT. 0) WRITE (LUPRI,'(/T6,A,I10,A)')
     &   'WARNING: matrix contains',N_NAN,' NaN.'
      IF (AMAX .EQ. ZERO) THEN
         WRITE (LUPRI,3000) NBLK
         GO TO 800
      END IF
      IF (FFMIN .LE. AMAX .AND. AMAX .LE. FFMAX) THEN
C        use F output format
         PFMT = '(A1,I7,2X,8F15.8)'
      ELSE
C        use 1PD output format
         PFMT = '(A1,I7,2X,1P,8D15.6)'
      END IF
C
      IOFF = 0
        DO 100 IBLK = 1,NBLK
        IDIM = NDIM(IBLK)
        IF (IDIM.EQ.0) GO TO 100
        I2DIM = IDIM*IDIM
          DO 10 I=1,I2DIM
          IF (AMATRX(IOFF+I).NE.ZERO) GO TO 15
   10     CONTINUE
        WRITE (LUPRI,1100) IBLK
        GO TO 90
   15   CONTINUE
        WRITE (LUPRI,1200) IBLK
        LAST = MIN(IDIM,KCOL)
          DO 2 BEGIN = 1,IDIM,KCOL
          WRITE (LUPRI,1000) (COLUMN,I,I = BEGIN,LAST)
            DO 1 K = 1,IDIM
            IOFFK = IOFF + K
            IF (MCTL .GE. 10) GO TO 5 ! also print zero rows
              DO 4 I=BEGIN,LAST
              IF (AMATRX(IOFFK+(I-1)*IDIM).NE.ZERO) GO TO 5
    4         CONTINUE
            GO TO 1
    5       WRITE (LUPRI,PFMT) CTL,K,(AMATRX(IOFFK+(I-1)*IDIM),
     *        I = BEGIN,LAST)
    1       CONTINUE
    2     LAST = MIN(LAST+KCOL,IDIM)
   90   IOFF = IOFF + I2DIM
  100   CONTINUE
C
  800 CONTINUE
      WRITE(LUPRI,'(A)') '    ==== End of matrix output ===='
      RETURN
 3000 FORMAT (/5X,'All',I3,' blocks zero matrices.')
 1100 FORMAT (/5X,'*** Block',I3,' zero matrix. ***')
 1200 FORMAT (/5X,'*** Block',I3,' ***')
 1000 FORMAT (/10X,8(5X,A6,I4))
      END
C  /* Deck output */
      SUBROUTINE OUTPUT (AMATRX,ROWLOW,ROWHI,COLLOW,COLHI,ROWDIM,COLDIM,
     *                   NCTL,LUPRI)
C.......................................................................
C Revised 15-Dec-1983 by Hans Jorgen Aa. Jensen.
C         16-Jun-1986 hjaaj ( removed Hollerith )
C
C OUTPUT PRINTS A REAL MATRIX IN FORMATTED FORM WITH NUMBERED ROWS
C AND COLUMNS.  THE INPUT IS AS FOLLOWS;
C
C        AMATRX(',').........MATRIX TO BE OUTPUT
C
C        ROWLOW..............ROW NUMBER AT WHICH OUTPUT IS TO BEGIN
C
C        ROWHI...............ROW NUMBER AT WHICH OUTPUT IS TO END
C
C        COLLOW..............COLUMN NUMBER AT WHICH OUTPUT IS TO BEGIN
C
C        COLHI...............COLUMN NUMBER AT WHICH OUTPUT IS TO END
C
C        ROWDIM..............ROW DIMENSION OF AMATRX(',')
C
C        COLDIM..............COLUMN DIMENSION OF AMATRX(',')
C
C        NCTL................CARRIAGE CONTROL FLAG; 1 FOR SINGLE SPACE
C                                                   2 FOR DOUBLE SPACE
C                                                   3 FOR TRIPLE SPACE
C                            hjaaj: negative for 132 col width
C
C THE PARAMETERS THAT FOLLOW MATRIX ARE ALL OF TYPE INTEGER.  THE
C PROGRAM IS SET UP TO HANDLE 5 COLUMNS/PAGE WITH A 1P,5D24.15 FORMAT
C FOR THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED,
C CHANGE FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER
C OF COLUMNS.
C
C AUTHOR;  NELSON H.F. BEEBE, QUANTUM THEORY PROJECT, UNIVERSITY OF
C          FLORIDA, GAINESVILLE
C REVISED; FEBRUARY 26, 1971
C
C.......................................................................
C
#include "implicit.h"
      INTEGER   ROWLOW,ROWHI,COLLOW,COLHI,ROWDIM,COLDIM,BEGIN,KCOL
      DIMENSION AMATRX(ROWDIM,COLDIM)
      CHARACTER*1 ASA(3), BLANK, CTL
      CHARACTER   PFMT*20, COLUMN*8
      LOGICAL     IS_NAN
      PARAMETER (ZERO=0.D00, KCOLP=5, KCOLN=8)
      PARAMETER (FFMIN=1.D-3, FFMAX = 1.D3)
      DATA COLUMN/'Column  '/, BLANK/' '/, ASA/' ', '0', '-'/
C
      N_NAN = 0
      IF (ROWHI.LT.ROWLOW) GO TO 3
      IF (COLHI.LT.COLLOW) GO TO 3
C
      AMAX = ZERO
      DO 10 J = COLLOW,COLHI
         DO 10 I = ROWLOW,ROWHI
            IF ( IS_NAN(AMATRX(I,J),AMATRX(I,J)) ) THEN
               N_NAN = N_NAN + 1
            ELSE
               AMAX = MAX( AMAX, ABS(AMATRX(I,J)) )
            END IF
   10 CONTINUE
      IF (N_NAN .GT. 0) WRITE (LUPRI,'(/T6,A,I10,A)')
     &   'WARNING: matrix contains',N_NAN,' NaN.'
      IF (AMAX .EQ. ZERO) THEN
         WRITE (LUPRI,'(/T6,A)') 'Zero matrix.'
         GO TO 3
      END IF
      IF (FFMIN .LE. AMAX .AND. AMAX .LE. FFMAX) THEN
C        use F output format
         PFMT = '(A1,I7,2X,8F15.8)'
         thrpri = 0.5D-8
      ELSE
C        use 1PE output format
         PFMT = '(A1,I7,2X,1P,8E15.6)'
         thrpri = 1.0D-8*AMAX
      END IF
C
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      LAST = MIN(COLHI,COLLOW+KCOL-1)
      DO 2 BEGIN = COLLOW,COLHI,KCOL
         WRITE (LUPRI,1000) (COLUMN,I,I = BEGIN,LAST)
         DO 1 K = ROWLOW,ROWHI
            IF (MCTL .GE. 10) GO TO 5 ! also print zero rows
            DO 4 I = BEGIN,LAST
               IF (abs(AMATRX(K,I)).gt.thrpri) GO TO 5
    4       CONTINUE
         GO TO 1
    5       WRITE (LUPRI,PFMT) CTL,K,(AMATRX(K,I), I = BEGIN,LAST)
    1    CONTINUE
    2 LAST = MIN(LAST+KCOL,COLHI)
    3 WRITE(LUPRI,'(A)') '    ==== End of matrix output ===='
      RETURN
 1000 FORMAT (/10X,8(5X,A6,I4))
      END
C  /* Deck Ioutput */
      SUBROUTINE IOUTPUT(IMATRX,ROWLOW,ROWHI,COLLOW,COLHI,ROWDIM,COLDIM,
     *                   NCTL,LUPRI)
C.......................................................................
C 04-Jun-2014 by Hans Jorgen Aa. Jensen.
C Based on OUTPUT.
C
C IOUTPUT PRINTS an integer MATRIX IN FORMATTED FORM WITH NUMBERED ROWS
C AND COLUMNS.  THE INPUT IS AS FOLLOWS;
C
C        IMATRX(',').........integer MATRIX TO BE OUTPUT
C
C        ROWLOW..............ROW NUMBER AT WHICH OUTPUT IS TO BEGIN
C
C        ROWHI...............ROW NUMBER AT WHICH OUTPUT IS TO END
C
C        COLLOW..............COLUMN NUMBER AT WHICH OUTPUT IS TO BEGIN
C
C        COLHI...............COLUMN NUMBER AT WHICH OUTPUT IS TO END
C
C        ROWDIM..............ROW DIMENSION OF IMATRX(',')
C
C        COLDIM..............COLUMN DIMENSION OF IMATRX(',')
C
C        NCTL................CARRIAGE CONTROL FLAG; 1 FOR SINGLE SPACE
C                                                   2 FOR DOUBLE SPACE
C                                                   3 FOR TRIPLE SPACE
C                            hjaaj: negative for 132 col width
C
C THE PARAMETERS THAT FOLLOW MATRIX ARE ALL OF TYPE INTEGER.  THE
C PROGRAM IS SET UP TO HANDLE 5 COLUMNS/PAGE WITH A 1P,5D24.15 FORMAT
C FOR THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED,
C CHANGE FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER
C OF COLUMNS.
C
C.......................................................................
C
#include "implicit.h"
      INTEGER   ROWLOW,ROWHI,COLLOW,COLHI,ROWDIM,COLDIM,BEGIN,KCOL
      INTEGER   IMATRX(ROWDIM,COLDIM), IM_MAX
      CHARACTER*1 ASA(3), BLANK, CTL
      CHARACTER   CFMT*20,PFMT*20, COLUMN*8
      DATA COLUMN/'Column  '/, BLANK/' '/, ASA/' ', '0', '-'/
C
      IF (ROWHI.LT.ROWLOW) GO TO 3
      IF (COLHI.LT.COLLOW) GO TO 3
C
      IM_MAX = 0
      DO 10 J = COLLOW,COLHI
         DO 10 I = ROWLOW,ROWHI
            IM_MAX = MAX( IM_MAX, ABS(IMATRX(I,J)) )
   10 CONTINUE
      IF (IM_MAX .EQ. 0) THEN
         WRITE (LUPRI,'(/T6,A)') 'Zero matrix.'
         GO TO 3
      END IF
      IF (IM_MAX .le. 1000000) THEN
         CFMT = '(/10X,20(1X,A3,I4))'
         PFMT = '(A1,I7,2X,20I8)'
         KCOLP =  8
         KCOLN = 15
      ELSE
         CFMT = '(/10X,8(5X,A6,I4))'
         PFMT = '(A1,I7,2X,8I15)'
         KCOLP = 5
         KCOLN = 8
      END IF
C
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      LAST = MIN(COLHI,COLLOW+KCOL-1)
      DO 2 BEGIN = COLLOW,COLHI,KCOL
         WRITE (LUPRI,CFMT) (COLUMN,I,I = BEGIN,LAST)
         DO 1 K = ROWLOW,ROWHI
            DO 4 I = BEGIN,LAST
               IF (abs(IMATRX(K,I)).gt.0) GO TO 5
    4       CONTINUE
         GO TO 1
    5       WRITE (LUPRI,PFMT) CTL,K,(IMATRX(K,I), I = BEGIN,LAST)
    1    CONTINUE
    2 LAST = MIN(LAST+KCOL,COLHI)
    3 WRITE(LUPRI,'(A)') '    ==== End of integer matrix output ===='
      RETURN
      END
C  /* Deck prtab */
      SUBROUTINE PRTAB(NTABLE,TABLE,TEXT,LUPRI)
C
C 28-Dec-1989 Hans Joergen Aa. Jensen
C
C Purpose: print tables of text (e.g. from input parsing routines)
C
      CHARACTER*(*) TABLE(NTABLE), TEXT
      LTEXT = LEN(TEXT)
      LTEXT = MIN(70,LTEXT)
      WRITE (LUPRI,'(//1X,A/1X,70A1/)') TEXT(1:LTEXT),('=',I=1,LTEXT)
      DO 100 I = 1,NTABLE
         IF (INDEX(TABLE(I),'XXXX') .EQ. 0) THEN
            WRITE (LUPRI,'(T6,A)') TABLE(I)
         END IF
  100 CONTINUE
      WRITE (LUPRI,'()')
      RETURN
      END
C  /* Deck prvec */
      SUBROUTINE PRVEC(NDIM,VEC,INCVEC,THRESH,MAXLIN,LUOUT)
C
C 19-Aug-1989 Hans Joergen Aa. Jensen
C
C   print VEC(1:NDIM*INCVEC:INCVEC)
C
C   NDIM      : Number of elements in vector VEC
C   VEC(:)    : Vector to be printed
C   INCVEC    : Increment between each element in vector VEC
C   THRESH    : Print threshold for vector with unit norm
C               (if THRESH .lt. 0 then -THRESH is used without
C                renormalization).
C   MAXLIN    : max. lines of output with vector elements
C   LUOUT     : output unit
C
C
#include "implicit.h"
      DIMENSION VEC(*)
      PARAMETER (D0 = 0.0D0, D1 = 1.0D0)
      PARAMETER (D1LOW = D1 - 1.0D-10, D1HGH = D1 + 1.0D-10)
      LOGICAL   VSCALE
C
C     Test input
C
      NERR = 0
      IF (NDIM   .LE. 0) THEN
         WRITE (LUOUT,'(/5X,A)')
     &     'No print from PRVEC because NDIM .le. 0'
         NERR = NERR + 1
      END IF
      IF (INCVEC .LE. 0) THEN
         WRITE (LUOUT,'(/5X,A)')
     &      'No print from PRVEC because INCVEC .le. 0'
         NERR = NERR + 1
      END IF
      IF (NERR .GT. 0) RETURN
C
C
C
      C2NRM = DNRM2(NDIM,VEC,INCVEC)
      IF (THRESH .LE. D0) THEN
         THRES2 = -THRESH
         VSCALE = .FALSE.
      ELSE
         THRES2 =  THRESH * C2NRM
         VSCALE = (C2NRM .LT. D1LOW .OR. C2NRM .GT. D1HGH)
      END IF
      IF (VSCALE) THEN
         WRITE (LUOUT,'(/2A,1P,D12.4)')
     &      ' Print of vector elements (vector scaled to unit norm)',
     &      ' larger than',ABS(THRESH)
         SCALE = D1 / C2NRM
      ELSE
         WRITE (LUOUT,'(/A,1P,D12.4)')
     &      ' Print of vector elements larger than',ABS(THRESH)
         SCALE = D1
      END IF
C
      IPR   = 0
      IZER  = 0
      C2SUM = D0
C
      DO 300 I = 1, NDIM
         NA = 1 + (I-1)*INCVEC
         IF (ABS(VEC(NA)).LE.THRES2 .OR. IPR .GE. MAXLIN) THEN
            C2SUM = C2SUM + VEC(NA)*VEC(NA)
            IF (VEC(NA) .EQ. D0) IZER = IZER + 1
         ELSE
            IF (MOD(IPR,5) .EQ. 0) WRITE (LUOUT,'()')
            IPR = IPR + 1
            IF (VSCALE) THEN
               WRITE(LUOUT,50)I,VEC(NA),SCALE*VEC(NA)
            ELSE
               WRITE(LUOUT,60)I,VEC(NA)
            END IF
   50       FORMAT(3X,'Element',I10,3X,'coefficient',1P,D10.2,0P,
     &             3X,'scaled to unit norm',F10.6)
   60       FORMAT(6X,'Element',I12,3X,'coefficient',F20.10)
         END IF
  300 CONTINUE
      IF (IPR .GE. MAXLIN) THEN
C
C     *** We have reached the print limit
C
         WRITE (LUOUT,910) IPR
      END IF
  910 FORMAT(/' Print limit of',I6,' elements has been reached.')
      C2SUM = SQRT(C2SUM)
      IF (IZER .EQ. NDIM) THEN
         WRITE (LUOUT,920) NDIM
      ELSE
         WRITE (LUOUT,930) NDIM,NDIM-IPR,IZER,C2SUM,C2NRM
      END IF
  920 FORMAT(/' Length of vector                      :',I10,
     *       /' All elements are zero.',/)
  930 FORMAT(/' Length of vector                      :',I10,
     *       /' Number of elements not printed        :',I10,
     *       /' Number of zero elements               :',I10,
     *       /' Total norm of coefficients not printed:',F10.6,
     *       /' (the coefficients are normalized to    ',F10.6,')',/)
      RETURN
C
C End of PRVEC
C
      END
C  /* Deck prmgn */
      SUBROUTINE PRMGN(NDIM,VEC,INCVEC,NPOT,LUOUT)
C
C 19-Aug-1989 hjaaj
C
C   NDIM      : Number of elements in vector VEC
C   VEC(:)    : Vector to be printed
C   INCVEC    : Increment between each element in vector VEC
C   NPOT      : IBASE**-NPOT is lowest magnitude considered
C   LUOUT     : output unit
C
C
#include "implicit.h"
      DIMENSION VEC(*)
      PARAMETER (D0 = 0.0D0, D1 = 1.0D0)
      PARAMETER (IBASE = 10)
C     IBASE     : Base for magnitude
C
      FACMGN = IBASE
      FACMGN = D1 / FACMGN
C
C     Test input
C
      NERR = 0
      IF (NDIM   .LE. 0) THEN
         WRITE (LUOUT,*) 'No print from PRMGN because NDIM .le. 0'
         NERR = NERR + 1
      END IF
      IF (INCVEC .LE. 0) THEN
         WRITE (LUOUT,*) 'No print from PRMGN because INCVEC .le. 0'
         NERR = NERR + 1
      END IF
      IF (NERR .GT. 0) RETURN
C
C
C
      C2NRM = DNRM2(NDIM,VEC,INCVEC)
      IZER  = 0
      NLAST = NDIM*INCVEC
      VECMAX = D0
      DO 100 NA = 1, NLAST, INCVEC
         IF (VEC(NA) .EQ. D0) THEN
            IZER = IZER + 1
         ELSE
            VECMAX = MAX(VECMAX, ABS(VEC(NA)) )
         END IF
  100 CONTINUE
C
C.... SIZE OF COEFFICIENTS
C
      WRITE(LUOUT,'(/A/A//A,2I12)')
     &  '  Magnitude of coefficients ',
     &  ' ===========================',
     &  '  Number of elements and increment:',NDIM,INCVEC
      IF (IZER .EQ. NDIM) THEN
         WRITE(LUOUT,'(/A)') '  All elements are zero.'
         GO TO 9999
      END IF
      WRITE(LUOUT,'(/A,1P,2E23.12)')
     &   '  Maximum abs value and vector norm:',VECMAX,C2NRM
C
      IF (C2NRM .GT. (D1 + 1.0 D-10) ) THEN
         WRITE (LUOUT,'(/A,1P,E23.12,A,/A)')
     &      ' (Vector norm is',C2NRM,')',
     &      ' (Range is scaled to a vector norm of 1)'
      END IF
      XMIN  = MAX(C2NRM,D1)
C     ... max possible coefficient is C2NRM
C
      WRITE (LUOUT,'(/2A,/2A)')
     &   '     Range        # of elements',
     &   '     Norm squared         Accumulated',
     &   ' -------------   --------------',
     &   '   ---------------     ---------------'
C
C Output will look like:
C
C     Range        # of elements     Norm squared         Accumulated
C -------------   --------------   ---------------     ---------------
C 10- 1 to  1                2      1.12345678E-01      1.12345678E-01
C
      C2NRM = D0
      IDET  = IZER
C. LOOP OVER INTERVALS
      IPOT  = 0
  200 CONTINUE
         CLNORM = D0
         INRANG = 0
         XMAX   = XMIN
         IF (IPOT .EQ. 0) XMAX = 2*XMAX
C        ... to make certain we don't omit any because of round-off
         XMIN   = XMIN * FACMGN
         DO 300 NA = 1, NLAST, INCVEC
           IF( ABS(VEC(NA)) .LE. XMAX  .AND.
     &         ABS(VEC(NA)) .GT. XMIN ) THEN
                 INRANG = INRANG + 1
                 CLNORM = CLNORM + VEC(NA) ** 2
           END IF
  300    CONTINUE
         C2NRM = C2NRM + CLNORM
C
C
         IF (INRANG .GT. 0) THEN
            IF (IPOT .EQ. 0) THEN
               WRITE(LUOUT,'(I3,A,I14,1P,2E20.8)')
     &            IBASE,'- 1 to  1   ',INRANG,CLNORM,C2NRM
            ELSE
               WRITE(LUOUT,'(I3,A,I2,A,I3,A,I2,I14,1P,2E20.8)')
     &            IBASE,'-',IPOT+1,' to',IBASE,'-',IPOT,
     &            INRANG,CLNORM,C2NRM
            END IF
         END IF
C
C
         IDET = IDET + INRANG
         IPOT = IPOT + 1
      IF( IDET .LT. NDIM .AND. IPOT .LT. NPOT ) GOTO 200
C
      ISML = NDIM - IDET
      IF (ISML .GT. 0) WRITE (LUOUT,'(A,I13)') ' Other non-zero ',ISML
      IF (IZER .GT. 0) WRITE (LUOUT,'(A,I13)') ' Exact zero     ',IZER
                     WRITE (LUOUT,'(/A,I13/)') ' Total          ',NDIM
C
C
 9999 CONTINUE
      RETURN
C
C End of PRMGN
C
      END
C  /* Deck pnzvec */
      FUNCTION PNZVEC(NDIM,VEC,INCVEC,THRZER)
C
C Copyright 24-Mar-1993 Hans Joergen Aagaard Jensen
C   return % non-zero elements of VEC(1:NDIM*INCVEC:INCVEC)
C
C   NDIM      : Number of elements in vector VEC
C   VEC(:)    : Vector
C   INCVEC    : Increment between each element in vector VEC
C   THRZER    : Threshold for zero elements
C
C
#include "implicit.h"
      DIMENSION VEC(*)
#include "priunit.h"
      PARAMETER (D0 = 0.0D0, D100 = 100.0D0)
C
C     Test input
C
      NERR = 0
      IF (NDIM   .LE. 0) THEN
         WRITE (LUPRI,'(/5X,A,I10)')
     &     'No percentage from PNZVEC because NDIM .le. 0; NDIM =',NDIM
         NERR = NERR + 1
      END IF
      IF (INCVEC .LE. 0) THEN
         WRITE (LUPRI,'(/5X,A,I10)')
     &      'No percentage from PNZVEC because INCVEC .le. 0; INCVEC =',
     &      INCVEC
         NERR = NERR + 1
      END IF
      IF (NERR .GT. 0) THEN
         PNZVEC = -D100
         RETURN
      END IF
C
      THRESH = MAX(D0,THRZER)
      NNZ = 0
      DO 100 I = 1,NDIM*INCVEC,INCVEC
         IF (ABS(VEC(I)) .GT. THRESH) NNZ = NNZ + 1
  100 CONTINUE
      DNZ    = NNZ
      DNDIM  = NDIM
      PNZVEC = DNZ*D100 / DNDIM
      RETURN
      END
C  /* Deck coutput */
      SUBROUTINE COUTPUT(AMATRX,ROWLOW,ROWHI,COLLOW,COLHI,ROWDIM,COLDIM,
     *                   NCTL,LUPRI)
C.......................................................................
C Revised 15-Dec-1983 by Hans Jorgen Aa. Jensen.
C         16-Jun-1986 hjaaj ( removed Hollerith )
C         20-Mar-2001 ov    complex matrix verison
C
C OUTPUT PRINTS A REAL MATRIX IN FORMATTED FORM WITH NUMBERED ROWS
C AND COLUMNS.  THE INPUT IS AS FOLLOWS;
C
C        AMATRX(',').........MATRIX TO BE OUTPUT
C
C        ROWLOW..............ROW NUMBER AT WHICH OUTPUT IS TO BEGIN
C
C        ROWHI...............ROW NUMBER AT WHICH OUTPUT IS TO END
C
C        COLLOW..............COLUMN NUMBER AT WHICH OUTPUT IS TO BEGIN
C
C        COLHI...............COLUMN NUMBER AT WHICH OUTPUT IS TO END
C
C        ROWDIM..............ROW DIMENSION OF AMATRX(',')
C
C        COLDIM..............COLUMN DIMENSION OF AMATRX(',')
C
C        NCTL................CARRIAGE CONTROL FLAG; 1 FOR SINGLE SPACE
C                                                   2 FOR DOUBLE SPACE
C                                                   3 FOR TRIPLE SPACE
C                            hjaaj: negative for 132 col width
C
C THE PARAMETERS THAT FOLLOW MATRIX ARE ALL OF TYPE INTEGER.  THE
C PROGRAM IS SET UP TO HANDLE 5 COLUMNS/PAGE WITH A 1P,5D24.15 FORMAT
C FOR THE COLUMNS.  IF A DIFFERENT NUMBER OF COLUMNS IS REQUIRED,
C CHANGE FORMATS 1000 AND 2000, AND INITIALIZE KCOL WITH THE NEW NUMBER
C OF COLUMNS.
C
C AUTHOR;  NELSON H.F. BEEBE, QUANTUM THEORY PROJECT, UNIVERSITY OF
C          FLORIDA, GAINESVILLE
C REVISED; FEBRUARY 26, 1971
C
C.......................................................................
C
      IMPLICIT DOUBLE COMPLEX (A-H,O-Z)
      INTEGER   ROWLOW,ROWHI,COLLOW,COLHI,ROWDIM,COLDIM,BEGIN,KCOL
      DIMENSION AMATRX(ROWDIM,COLDIM)
      COMPLEX   C4_test           ! hjaaj: for testing elements for print
      REAL*4    R4_test,R4_thrpri !        because no double complex absolute value :-(
      CHARACTER*1 ASA(3), BLANK, CTL
      CHARACTER   PFMT*30, COLUMN*8
      DOUBLE PRECISION ZERO, FFMIN, FFMAX
      PARAMETER (ZERO=0.D00, KCOLP=4, KCOLN=6)
      PARAMETER (FFMIN=1.D-3, FFMAX = 1.D3)
      DATA COLUMN/'Column  '/, BLANK/' '/, ASA/' ', '0', '-'/
      DOUBLE PRECISION AMAX
C
      IF (ROWHI.LT.ROWLOW) GO TO 3
      IF (COLHI.LT.COLLOW) GO TO 3
C
      AMAX = ZERO
      DO 10 J = COLLOW,COLHI
         DO 10 I = ROWLOW,ROWHI
            AMAX = MAX( AMAX, ABS(AMATRX(I,J)) )
   10 CONTINUE
      IF (AMAX .EQ. ZERO) THEN
         WRITE (LUPRI,'(/T6,A)') 'Zero matrix.'
         GO TO 3
      END IF
      IF (FFMIN .LE. AMAX .AND. AMAX .LE. FFMAX) THEN
C        use F output format
         PFMT = '(A1,I7,2X,6(F17.8,F13.8))'
         thrpri = 0.5D-6
      ELSE
C        use 1PD output format
         PFMT = '(A1,I7,2X,1P,6(D17.6,D13.6))'
         thrpri = 1.0D-6*AMAX
      END IF
C
      IF (NCTL .LT. 0) THEN
         KCOL = KCOLN
      ELSE
         KCOL = KCOLP
      END IF
      MCTL = ABS(NCTL)
      IF ((MCTL.LE.3).AND.(MCTL.GT.0)) THEN
         CTL = ASA(MCTL)
      ELSE
         CTL = BLANK
      END IF
C
      R4_thrpri = thrpri
      LAST = MIN(COLHI,COLLOW+KCOL-1)
      DO 2 BEGIN = COLLOW,COLHI,KCOL
         WRITE (LUPRI,1000) (COLUMN,I,I = BEGIN,LAST)
         DO 1 K = ROWLOW,ROWHI
            IF (MCTL .GE. 10) GO TO 5 ! also print zero rows
            DO 4 I = BEGIN,LAST
               C4_test = AMATRX(K,I)   ! hjaaj: all this because no intrinsic routine to
               R4_test = cabs(C4_test) !        calculate absolute value of double complex number
               IF (R4_test .gt. R4_thrpri) GO TO 5
    4       CONTINUE
         GO TO 1
    5       WRITE (LUPRI,PFMT) CTL,K,(AMATRX(K,I), I = BEGIN,LAST)
    1    CONTINUE
    2 LAST = MIN(LAST+KCOL,COLHI)
    3 WRITE(LUPRI,'(A)') '    ==== End of matrix output ===='
      RETURN
 1000 FORMAT (/10X,6('      real < ',A6,I4,' > imag'))
      END
C === Deck is_nan ===============
      LOGICAL FUNCTION IS_NAN(XA,XB)
C
C     May 2010, Hans Joergen Aa. Jensen
C     Purpose: IS_NAN(X,X) is true iff X is NAN
C
      REAL*8 XA, XB
      IS_NAN = XA .NE. XB
      RETURN
      END
C === Deck n_nan ===============
      INTEGER FUNCTION N_NAN(N,AVEC)
C
C     May 2010, Hans Joergen Aa. Jensen
C     Purpose: N_NAN returns number of NAN entries in AVEC(1:N)
C
      REAL*8 AVEC(N)
      N_NAN  = N_NOT_EQUAL(N,AVEC,AVEC)
      RETURN
      END
C === Deck n_not_equal ===============
      INTEGER FUNCTION N_NOT_EQUAL(N,AVEC,BVEC)
C
C     May 2010, Hans Joergen Aa. Jensen
C     Purpose: Number of not equal elements in AVEC and BVEC
C
C     NOTE: N_NOT_EQUAL(N,DA,DA) is number of NAN elements in DA(1:N)
C
      INTEGER N, I, J
      REAL*8  AVEC(N), BVEC(N)
      J = 0
      DO I = 1,N
         IF ( AVEC(I) .NE. BVEC(I) ) J = J + 1
      END DO
      N_NOT_EQUAL = J
      RETURN
      END
C -------- end of printpkg.F -----------
