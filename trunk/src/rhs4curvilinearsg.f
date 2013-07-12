c-----------------------------------------------------------------------
      subroutine FREESURFCURVISG( ifirst, ilast, jfirst, jlast, kfirst,
     *     klast, nz, side, u, mu, la, met, s, forcing, strx, stry )
      implicit none
      real*8 c1, c2
      parameter( c1=2d0/3, c2=-1d0/12 )

      integer ifirst, ilast, jfirst, jlast, kfirst, klast
      integer i, j, k, kl, nz, side
      real*8 u(3,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 met(4,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 mu(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 la(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 forcing(3,ifirst:ilast,jfirst:jlast)
      real*8 strx(ifirst:ilast), stry(jfirst:jlast)
      real*8 s(0:4), rhs1, rhs2, rhs3, s0i, ac, bc, cc, dc
      real*8 istry, istrx, xoysqrt, yoxsqrt, isqrtxy

      if( side.eq.5 )then
         k = 1
         kl= 1
      elseif( side.eq.6 )then
         k = nz
         kl= -1
      endif

      s0i = 1/s(0)
      do j=jfirst+2,jlast-2
         istry = 1/stry(j)
         do i=ifirst+2,ilast-2
            istrx = 1/strx(i)

*** First tangential derivatives
            rhs1 = 
*** pr
     *   (2*mu(i,j,k)+la(i,j,k))*met(2,i,j,k)*met(1,i,j,k)*(
     *          c2*(u(1,i+2,j,k)-u(1,i-2,j,k)) +
     *          c1*(u(1,i+1,j,k)-u(1,i-1,j,k))  )*strx(i)*istry 
     *  + mu(i,j,k)*met(3,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(2,i+2,j,k)-u(2,i-2,j,k)) +
     *        c1*(u(2,i+1,j,k)-u(2,i-1,j,k))  ) 
     *  + mu(i,j,k)*met(4,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(3,i+2,j,k)-u(3,i-2,j,k)) +
     *        c1*(u(3,i+1,j,k)-u(3,i-1,j,k))  )*istry   
*** qr
     *  + mu(i,j,k)*met(3,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(1,i,j+2,k)-u(1,i,j-2,k)) +
     *        c1*(u(1,i,j+1,k)-u(1,i,j-1,k))   )*istrx*stry(j) 
     *  + la(i,j,k)*met(2,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(2,i,j+2,k)-u(2,i,j-2,k)) +
     *        c1*(u(2,i,j+1,k)-u(2,i,j-1,k))  )  -
     *                 forcing(1,i,j)

*** (v-eq)
            rhs2 = 
*** pr
     *    la(i,j,k)*met(3,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(1,i+2,j,k)-u(1,i-2,j,k)) +
     *        c1*(u(1,i+1,j,k)-u(1,i-1,j,k))   ) 
     *  + mu(i,j,k)*met(2,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(2,i+2,j,k)-u(2,i-2,j,k)) +
     *        c1*(u(2,i+1,j,k)-u(2,i-1,j,k))  )*strx(i)*istry 
*** qr
     *  + mu(i,j,k)*met(2,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(1,i,j+2,k)-u(1,i,j-2,k)) +
     *        c1*(u(1,i,j+1,k)-u(1,i,j-1,k))   ) 
     * + (2*mu(i,j,k)+la(i,j,k))*met(3,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(2,i,j+2,k)-u(2,i,j-2,k)) +
     *        c1*(u(2,i,j+1,k)-u(2,i,j-1,k))  )*stry(j)*istrx 
     *  + mu(i,j,k)*met(4,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(3,i,j+2,k)-u(3,i,j-2,k)) +
     *        c1*(u(3,i,j+1,k)-u(3,i,j-1,k))   )*istrx -
     *                  forcing(2,i,j)

*** (w-eq)
            rhs3 = 
*** pr
     *    la(i,j,k)*met(4,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(1,i+2,j,k)-u(1,i-2,j,k)) +
     *        c1*(u(1,i+1,j,k)-u(1,i-1,j,k))   )*istry 
     *  + mu(i,j,k)*met(2,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(3,i+2,j,k)-u(3,i-2,j,k)) +
     *        c1*(u(3,i+1,j,k)-u(3,i-1,j,k))  )*strx(i)*istry
*** qr 
     *  + mu(i,j,k)*met(3,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(3,i,j+2,k)-u(3,i,j-2,k)) +
     *        c1*(u(3,i,j+1,k)-u(3,i,j-1,k))   )*stry(j)*istrx
     *  + la(i,j,k)*met(4,i,j,k)*met(1,i,j,k)*(
     *        c2*(u(2,i,j+2,k)-u(2,i,j-2,k)) +
     *        c1*(u(2,i,j+1,k)-u(2,i,j-1,k))  )*istrx -
     *                  forcing(3,i,j)

*** Normal derivatives
            ac = strx(i)*istry*met(2,i,j,k)**2+
     *         stry(j)*istrx*met(3,i,j,k)**2+met(4,i,j,k)**2*istry*istrx
            bc = 1/(mu(i,j,k)*ac)
            cc = (mu(i,j,k)+la(i,j,k))/(2*mu(i,j,k)+la(i,j,k))*bc/ac

            xoysqrt = SQRT(strx(i)*istry)
            yoxsqrt = 1/xoysqrt
            isqrtxy = istrx*xoysqrt
            dc = cc*( xoysqrt*met(2,i,j,k)*rhs1 + 
     *           yoxsqrt*met(3,i,j,k)*rhs2 + isqrtxy*met(4,i,j,k)*rhs3)

            u(1,i,j,k-kl) = -s0i*(  s(1)*u(1,i,j,k)+s(2)*u(1,i,j,k+kl)+
     *           s(3)*u(1,i,j,k+2*kl)+s(4)*u(1,i,j,k+3*kl) + bc*rhs1 - 
     *                                       dc*met(2,i,j,k)*xoysqrt )
            u(2,i,j,k-kl) = -s0i*(  s(1)*u(2,i,j,k)+s(2)*u(2,i,j,k+kl)+
     *           s(3)*u(2,i,j,k+2*kl)+s(4)*u(2,i,j,k+3*kl) + bc*rhs2 - 
     *                                       dc*met(3,i,j,k)*yoxsqrt )
            u(3,i,j,k-kl) = -s0i*(  s(1)*u(3,i,j,k)+s(2)*u(3,i,j,k+kl)+
     *           s(3)*u(3,i,j,k+2*kl)+s(4)*u(3,i,j,k+3*kl) + bc*rhs3 - 
     *                                       dc*met(4,i,j,k)*isqrtxy )
c            ac = strx(i)*istry*met(2,i,j,k)**2+
c     *                stry(j)*istrx*met(3,i,j,k)**2+met(4,i,j,k)**2
c            bc = 1/(mu(i,j,k)*ac)
c            cc = (mu(i,j,k)+la(i,j,k))/(2*mu(i,j,k)+la(i,j,k))*bc/ac
c
c            xoysqrt = SQRT(strx(i)*istry)
c            yoxsqrt = 1/xoysqrt
c
c            dc = cc*( xoysqrt*met(2,i,j,k)*rhs1 + 
c     *                yoxsqrt*met(3,i,j,k)*rhs2 + met(4,i,j,k)*rhs3)
c
c            u(1,i,j,k-kl) = -s0i*(  s(1)*u(1,i,j,k)+s(2)*u(1,i,j,k+kl)+
c     *           s(3)*u(1,i,j,k+2*kl)+s(4)*u(1,i,j,k+3*kl) + bc*rhs1 - 
c     *                                       dc*met(2,i,j,k)*xoysqrt )
c            u(2,i,j,k-kl) = -s0i*(  s(1)*u(2,i,j,k)+s(2)*u(2,i,j,k+kl)+
c     *           s(3)*u(2,i,j,k+2*kl)+s(4)*u(2,i,j,k+3*kl) + bc*rhs2 - 
c     *                                       dc*met(3,i,j,k)*yoxsqrt )
c            u(3,i,j,k-kl) = -s0i*(  s(1)*u(3,i,j,k)+s(2)*u(3,i,j,k+kl)+
c     *           s(3)*u(3,i,j,k+2*kl)+s(4)*u(3,i,j,k+3*kl) + bc*rhs3 - 
c     *                                       dc*met(4,i,j,k) )
         enddo
      enddo
      end

c-----------------------------------------------------------------------
      subroutine GETSURFFORCINGSG( ifirst, ilast, jfirst, jlast, kfirst,
     *     klast, k, met, jac, tau, strx, stry, forcing )
***********************************************************************
***
*** Given tau, Cartesian stress tensor on boundary, compute the stress
*** normal to the k=1 boundary of a curvilinear grid.
***
*** tau is ordered as:
***    tau(1) = t_{xx}, tau(2) = t_{xy} tau(3) = t_{xz} 
***    tau(4) = t_{yy}, tau(5) = t_{yz} tau(6) = t_{zz}
***
***********************************************************************
      implicit none
      integer ifirst, ilast, jfirst, jlast, kfirst, klast
      integer i, j, k
      real*8 met(4,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 tau(6,ifirst:ilast,jfirst:jlast)
      real*8 forcing(3,ifirst:ilast,jfirst:jlast)
      real*8 jac(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 strx(ifirst:ilast), stry(jfirst:jlast)
      real*8 sqjac, istrx, istry
      do j=jfirst,jlast
         istry = 1/stry(j)
         do i=ifirst,ilast
            istrx = 1/strx(i)
            sqjac = SQRT(jac(i,j,k))
            forcing(1,i,j) =  sqjac*( istry*met(2,i,j,k)*tau(1,i,j)+
     *                                istrx*met(3,i,j,k)*tau(2,i,j)+
     *                          istrx*istry*met(4,i,j,k)*tau(3,i,j) )
            forcing(2,i,j) =  sqjac*( istry*met(2,i,j,k)*tau(2,i,j)+
     *                                istrx*met(3,i,j,k)*tau(4,i,j)+
     *                          istrx*istry*met(4,i,j,k)*tau(5,i,j) )
            forcing(3,i,j) =  sqjac*( istry*met(2,i,j,k)*tau(3,i,j)+
     *                                istrx*met(3,i,j,k)*tau(5,i,j)+
     *                          istrx*istry*met(4,i,j,k)*tau(6,i,j) )
         enddo
      enddo
      end

c-----------------------------------------------------------------------
      subroutine SUBSURFFORCINGSG( ifirst, ilast, jfirst, jlast, kfirst,
     *     klast, k, met, jac, tau, strx, stry, forcing )
***********************************************************************
***
*** Given tau, Cartesian stress tensor on boundary, compute the stress
*** normal to the k=1 boundary of a curvilinear grid.
***
*** tau is ordered as:
***    tau(1) = t_{xx}, tau(2) = t_{xy} tau(3) = t_{xz} 
***    tau(4) = t_{yy}, tau(5) = t_{yz} tau(6) = t_{zz}
***
***********************************************************************
      implicit none
      integer ifirst, ilast, jfirst, jlast, kfirst, klast
      integer i, j, k
      real*8 met(4,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 tau(6,ifirst:ilast,jfirst:jlast)
      real*8 forcing(3,ifirst:ilast,jfirst:jlast)
      real*8 jac(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 strx(ifirst:ilast), stry(jfirst:jlast)
      real*8 sqjac, istrx, istry
      do j=jfirst,jlast
         istry = 1/stry(j)
         do i=ifirst,ilast
            istrx = 1/strx(i)
            sqjac = SQRT(jac(i,j,k))
c            if( i.eq.23 .and. j.eq.18 )then
c               write(*,*) 'twf ',sqjac*( istry*met(2,i,j,k)*tau(1,i,j)+
c     *                                istrx*met(3,i,j,k)*tau(2,i,j)+
c     *                          istrx*istry*met(4,i,j,k)*tau(3,i,j) )
c            endif
            forcing(1,i,j) =  forcing(1,i,j) -
     *                        sqjac*( istry*met(2,i,j,k)*tau(1,i,j)+
     *                                istrx*met(3,i,j,k)*tau(2,i,j)+
     *                          istrx*istry*met(4,i,j,k)*tau(3,i,j) )
            forcing(2,i,j) =  forcing(2,i,j) -
     *                        sqjac*( istry*met(2,i,j,k)*tau(2,i,j)+
     *                                istrx*met(3,i,j,k)*tau(4,i,j)+
     *                          istrx*istry*met(4,i,j,k)*tau(5,i,j) )
            forcing(3,i,j) =  forcing(3,i,j) -
     *                        sqjac*( istry*met(2,i,j,k)*tau(3,i,j)+
     *                                istrx*met(3,i,j,k)*tau(5,i,j)+
     *                          istrx*istry*met(4,i,j,k)*tau(6,i,j) )
         enddo
      enddo
      end

c-----------------------------------------------------------------------
      subroutine CURVILINEAR4SG( ifirst, ilast, jfirst, jlast, kfirst,
     *                         klast, u, mu, la, met, jac, lu, 
     *                         onesided, acof, bope, ghcof, strx, stry,
     *                         op )


*** Routine with supergrid stretchings strx and stry. No stretching
*** in z, since top is always topography, and bottom always interface
*** to a deeper Cartesian grid.

      implicit none
      real*8 c1, c2, tf, i6, i144
      parameter( c1=2d0/3, c2=-1d0/12 )
      parameter( tf=3d0/4, i6=1d0/6, i144=1d0/144 )

      integer ifirst, ilast, jfirst, jlast, kfirst, klast
      integer i, j, k, m, q, kstart, onesided(6)
      real*8 u(3,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 Lu(3,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 met(4,ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 mu(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 la(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 jac(ifirst:ilast,jfirst:jlast,kfirst:klast)
      real*8 cof1, cof2, cof3, cof4, cof5, r1, r2, r3, ijac
      real*8 mux1, mux2, mux3, mux4, a1, sgn
      real*8 mucofu2, mucofuv, mucofuw, mucofv2, mucofvw, mucofw2
      real*8 ghcof(6), acof(6,8,8), bope(6,8)
      real*8 dudrp2, dudrp1, dudrm1, dudrm2
      real*8 dvdrp2, dvdrp1, dvdrm1, dvdrm2
      real*8 dwdrp2, dwdrp1, dwdrm1, dwdrm2
      real*8 strx(ifirst:ilast), stry(jfirst:jlast)
      real*8 istrx, istry, istrxy
      character*1 op

*** met(1) is sqrt(J)*px = sqrt(J)*qy
*** met(2) is sqrt(J)*rx
*** met(3) is sqrt(J)*ry
*** met(4) is sqrt(J)*rz

      if( op.eq.'=' )then
         a1 = 0
         sgn= 1
      elseif( op.eq.'+')then
         a1 = 1
         sgn= 1
      elseif( op.eq.'-')then
         a1 = 1
         sgn=-1
      endif

      kstart = kfirst+2
      if( onesided(5).eq.1 )then
         kstart = 7

*** SBP Boundary closure terms
         do k=1,6
            do j=jfirst+2,jlast-2
               do i=ifirst+2,ilast-2
               ijac   = strx(i)*stry(j)/jac(i,j,k)
               istry  = 1/(stry(j))
               istrx  = 1/(strx(i))
               istrxy = istry*istrx

               r1 = 0
               r2 = 0
               r3 = 0

*** pp derivative (u) (u-eq)

          cof1=(2*mu(i-2,j,k)+la(i-2,j,k))*met(1,i-2,j,k)*met(1,i-2,j,k)
     *                                              *strx(i-2)
          cof2=(2*mu(i-1,j,k)+la(i-1,j,k))*met(1,i-1,j,k)*met(1,i-1,j,k)
     *                                              *strx(i-1)
          cof3=(2*mu(i,j,k)+la(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*strx(i)
          cof4=(2*mu(i+1,j,k)+la(i+1,j,k))*met(1,i+1,j,k)*met(1,i+1,j,k)
     *                                              *strx(i+1)
          cof5=(2*mu(i+2,j,k)+la(i+2,j,k))*met(1,i+2,j,k)*met(1,i+2,j,k)
     *                                              *strx(i+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i-2,j,k)-u(1,i,j,k)) + 
     *               mux2*(u(1,i-1,j,k)-u(1,i,j,k)) + 
     *               mux3*(u(1,i+1,j,k)-u(1,i,j,k)) +
     *               mux4*(u(1,i+2,j,k)-u(1,i,j,k))  )*istry

*** qq derivative (u) (u-eq)
          cof1=(mu(i,j-2,k))*met(1,i,j-2,k)*met(1,i,j-2,k)*stry(j-2)
          cof2=(mu(i,j-1,k))*met(1,i,j-1,k)*met(1,i,j-1,k)*stry(j-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*stry(j)
          cof4=(mu(i,j+1,k))*met(1,i,j+1,k)*met(1,i,j+1,k)*stry(j+1)
          cof5=(mu(i,j+2,k))*met(1,i,j+2,k)*met(1,i,j+2,k)*stry(j+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i,j-2,k)-u(1,i,j,k)) + 
     *               mux2*(u(1,i,j-1,k)-u(1,i,j,k)) + 
     *               mux3*(u(1,i,j+1,k)-u(1,i,j,k)) +
     *               mux4*(u(1,i,j+2,k)-u(1,i,j,k))  )*istrx

*** pp derivative (v) (v-eq)
          cof1=(mu(i-2,j,k))*met(1,i-2,j,k)*met(1,i-2,j,k)*strx(i-2)
          cof2=(mu(i-1,j,k))*met(1,i-1,j,k)*met(1,i-1,j,k)*strx(i-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*strx(i)
          cof4=(mu(i+1,j,k))*met(1,i+1,j,k)*met(1,i+1,j,k)*strx(i+1)
          cof5=(mu(i+2,j,k))*met(1,i+2,j,k)*met(1,i+2,j,k)*strx(i+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r2 = r2 + i6* (
     *               mux1*(u(2,i-2,j,k)-u(2,i,j,k)) + 
     *               mux2*(u(2,i-1,j,k)-u(2,i,j,k)) + 
     *               mux3*(u(2,i+1,j,k)-u(2,i,j,k)) +
     *               mux4*(u(2,i+2,j,k)-u(2,i,j,k))  )*istry

*** qq derivative (v) (v-eq)
          cof1=(2*mu(i,j-2,k)+la(i,j-2,k))*met(1,i,j-2,k)*met(1,i,j-2,k)
     *                                                     *stry(j-2)
          cof2=(2*mu(i,j-1,k)+la(i,j-1,k))*met(1,i,j-1,k)*met(1,i,j-1,k)
     *                                                     *stry(j-1)
          cof3=(2*mu(i,j,k)+la(i,j,k))*met(1,i,j,k)*met(1,i,j,k)
     *                                                     *stry(j)
          cof4=(2*mu(i,j+1,k)+la(i,j+1,k))*met(1,i,j+1,k)*met(1,i,j+1,k)
     *                                                     *stry(j+1)
          cof5=(2*mu(i,j+2,k)+la(i,j+2,k))*met(1,i,j+2,k)*met(1,i,j+2,k)
     *                                                     *stry(j+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r2 = r2 + i6* (
     *               mux1*(u(2,i,j-2,k)-u(2,i,j,k)) + 
     *               mux2*(u(2,i,j-1,k)-u(2,i,j,k)) + 
     *               mux3*(u(2,i,j+1,k)-u(2,i,j,k)) +
     *               mux4*(u(2,i,j+2,k)-u(2,i,j,k))  )*istrx

*** pp derivative (w) (w-eq)
          cof1=(mu(i-2,j,k))*met(1,i-2,j,k)*met(1,i-2,j,k)*strx(i-2)
          cof2=(mu(i-1,j,k))*met(1,i-1,j,k)*met(1,i-1,j,k)*strx(i-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*strx(i)
          cof4=(mu(i+1,j,k))*met(1,i+1,j,k)*met(1,i+1,j,k)*strx(i+1)
          cof5=(mu(i+2,j,k))*met(1,i+2,j,k)*met(1,i+2,j,k)*strx(i+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r3 = r3 + i6* (
     *               mux1*(u(3,i-2,j,k)-u(3,i,j,k)) + 
     *               mux2*(u(3,i-1,j,k)-u(3,i,j,k)) + 
     *               mux3*(u(3,i+1,j,k)-u(3,i,j,k)) +
     *               mux4*(u(3,i+2,j,k)-u(3,i,j,k))  )*istry

*** qq derivative (w) (w-eq)
          cof1=(mu(i,j-2,k))*met(1,i,j-2,k)*met(1,i,j-2,k)*stry(j-2)
          cof2=(mu(i,j-1,k))*met(1,i,j-1,k)*met(1,i,j-1,k)*stry(j-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*stry(j)
          cof4=(mu(i,j+1,k))*met(1,i,j+1,k)*met(1,i,j+1,k)*stry(j+1)
          cof5=(mu(i,j+2,k))*met(1,i,j+2,k)*met(1,i,j+2,k)*stry(j+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r3 = r3 + i6* (
     *               mux1*(u(3,i,j-2,k)-u(3,i,j,k)) + 
     *               mux2*(u(3,i,j-1,k)-u(3,i,j,k)) + 
     *               mux3*(u(3,i,j+1,k)-u(3,i,j,k)) +
     *               mux4*(u(3,i,j+2,k)-u(3,i,j,k))  )*istrx


*** All rr-derivatives at once
*** averaging the coefficient
            do q=1,8
               mucofu2=0
               mucofuv=0
               mucofuw=0
               mucofvw=0
               mucofv2=0
               mucofw2=0
               do m=1,8
                  mucofu2 = mucofu2 +
     *             acof(k,q,m)*((2*mu(i,j,m)+la(i,j,m))*
     *                                  (met(2,i,j,m)*strx(i))**2
     *                           + mu(i,j,m)*
     *                   ((met(3,i,j,m)*stry(j))**2+met(4,i,j,m)**2))
                  mucofv2 = mucofv2+
     *             acof(k,q,m)*((2*mu(i,j,m)+la(i,j,m))*
     *                                  (met(3,i,j,m)*stry(j))**2
     *                              + mu(i,j,m)*
     *                    ((met(2,i,j,m)*strx(i))**2+met(4,i,j,m)**2))
                  mucofw2 = mucofw2+
     *             acof(k,q,m)*((2*mu(i,j,m)+la(i,j,m))*met(4,i,j,m)**2
     *                       + mu(i,j,m)*
     *           ((met(2,i,j,m)*strx(i))**2+(met(3,i,j,m)*stry(j))**2))
                  mucofuv = mucofuv+acof(k,q,m)*(mu(i,j,m)+la(i,j,m))*
     *                 met(2,i,j,m)*met(3,i,j,m)
                  mucofuw = mucofuw+acof(k,q,m)*(mu(i,j,m)+la(i,j,m))*
     *                 met(2,i,j,m)*met(4,i,j,m)
                  mucofvw = mucofvw+acof(k,q,m)*(mu(i,j,m)+la(i,j,m))*
     *                 met(3,i,j,m)*met(4,i,j,m)
              enddo
*** Computing the second derivative,
              r1 = r1 + istrxy*mucofu2*u(1,i,j,q) + mucofuv*u(2,i,j,q) + 
     *                                         istry*mucofuw*u(3,i,j,q)
              r2 = r2 + mucofuv*u(1,i,j,q) + istrxy*mucofv2*u(2,i,j,q) + 
     *                                         istrx*mucofvw*u(3,i,j,q)
              r3 = r3 + istry*mucofuw*u(1,i,j,q) + 
     *              istrx*mucofvw*u(2,i,j,q) + istrxy*mucofw2*u(3,i,j,q)
            end do

*** Ghost point values, only nonzero for k=1.
            mucofu2 = ghcof(k)*((2*mu(i,j,1)+la(i,j,1))*
     *                           (met(2,i,j,1)*strx(i))**2
     *        + mu(i,j,1)*((met(3,i,j,1)*stry(j))**2+met(4,i,j,1)**2))
            mucofv2 = ghcof(k)*((2*mu(i,j,1)+la(i,j,1))*
     *                           (met(3,i,j,1)*stry(j))**2
     *         + mu(i,j,1)*((met(2,i,j,1)*strx(i))**2+met(4,i,j,1)**2))
            mucofw2 = ghcof(k)*((2*mu(i,j,1)+la(i,j,1))*met(4,i,j,1)**2
     *                             + mu(i,j,1)*
     *           ((met(2,i,j,1)*strx(i))**2+(met(3,i,j,1)*stry(j))**2))
            mucofuv = ghcof(k)*(mu(i,j,1)+la(i,j,1))*
     *                 met(2,i,j,1)*met(3,i,j,1)
            mucofuw = ghcof(k)*(mu(i,j,1)+la(i,j,1))*
     *                 met(2,i,j,1)*met(4,i,j,1)
            mucofvw = ghcof(k)*(mu(i,j,1)+la(i,j,1))*
     *                 met(3,i,j,1)*met(4,i,j,1)
            r1 = r1 + istrxy*mucofu2*u(1,i,j,0) + mucofuv*u(2,i,j,0) + 
     *                                        istry*mucofuw*u(3,i,j,0)
            r2 = r2 + mucofuv*u(1,i,j,0) + istrxy*mucofv2*u(2,i,j,0) + 
     *                                        istrx*mucofvw*u(3,i,j,0)
            r3 = r3 + istry*mucofuw*u(1,i,j,0) + 
     *            istrx*mucofvw*u(2,i,j,0) + istrxy*mucofw2*u(3,i,j,0)

*** pq-derivatives (u-eq)
      r1 = r1 + 
     *   c2*(  mu(i,j+2,k)*met(1,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(2,i+2,j+2,k)-u(2,i-2,j+2,k)) +
     *        c1*(u(2,i+1,j+2,k)-u(2,i-1,j+2,k))    )
     *     - mu(i,j-2,k)*met(1,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(2,i+2,j-2,k)-u(2,i-2,j-2,k))+
     *        c1*(u(2,i+1,j-2,k)-u(2,i-1,j-2,k))     )
     *     ) +
     *   c1*(  mu(i,j+1,k)*met(1,i,j+1,k)*met(1,i,j+1,k)*(
     *          c2*(u(2,i+2,j+1,k)-u(2,i-2,j+1,k)) +
     *          c1*(u(2,i+1,j+1,k)-u(2,i-1,j+1,k))  )
     *      - mu(i,j-1,k)*met(1,i,j-1,k)*met(1,i,j-1,k)*(
     *          c2*(u(2,i+2,j-1,k)-u(2,i-2,j-1,k)) + 
     *          c1*(u(2,i+1,j-1,k)-u(2,i-1,j-1,k))))

*** qp-derivatives (u-eq)
      r1 = r1 + 
     *   c2*(  la(i+2,j,k)*met(1,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(2,i+2,j+2,k)-u(2,i+2,j-2,k)) +
     *        c1*(u(2,i+2,j+1,k)-u(2,i+2,j-1,k))    )
     *     - la(i-2,j,k)*met(1,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(2,i-2,j+2,k)-u(2,i-2,j-2,k))+
     *        c1*(u(2,i-2,j+1,k)-u(2,i-2,j-1,k))     )
     *     ) +
     *   c1*(  la(i+1,j,k)*met(1,i+1,j,k)*met(1,i+1,j,k)*(
     *          c2*(u(2,i+1,j+2,k)-u(2,i+1,j-2,k)) +
     *          c1*(u(2,i+1,j+1,k)-u(2,i+1,j-1,k))  )
     *      - la(i-1,j,k)*met(1,i-1,j,k)*met(1,i-1,j,k)*(
     *          c2*(u(2,i-1,j+2,k)-u(2,i-1,j-2,k)) + 
     *          c1*(u(2,i-1,j+1,k)-u(2,i-1,j-1,k))))

*** pq-derivatives (v-eq)
      r2 = r2 + 
     *   c2*(  la(i,j+2,k)*met(1,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(1,i+2,j+2,k)-u(1,i-2,j+2,k)) +
     *        c1*(u(1,i+1,j+2,k)-u(1,i-1,j+2,k))    )
     *     - la(i,j-2,k)*met(1,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(1,i+2,j-2,k)-u(1,i-2,j-2,k))+
     *        c1*(u(1,i+1,j-2,k)-u(1,i-1,j-2,k))     )
     *     ) +
     *   c1*(  la(i,j+1,k)*met(1,i,j+1,k)*met(1,i,j+1,k)*(
     *          c2*(u(1,i+2,j+1,k)-u(1,i-2,j+1,k)) +
     *          c1*(u(1,i+1,j+1,k)-u(1,i-1,j+1,k))  )
     *      - la(i,j-1,k)*met(1,i,j-1,k)*met(1,i,j-1,k)*(
     *          c2*(u(1,i+2,j-1,k)-u(1,i-2,j-1,k)) + 
     *          c1*(u(1,i+1,j-1,k)-u(1,i-1,j-1,k))))

*** qp-derivatives (v-eq)
      r2 = r2 + 
     *   c2*(  mu(i+2,j,k)*met(1,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(1,i+2,j+2,k)-u(1,i+2,j-2,k)) +
     *        c1*(u(1,i+2,j+1,k)-u(1,i+2,j-1,k))    )
     *     - mu(i-2,j,k)*met(1,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(1,i-2,j+2,k)-u(1,i-2,j-2,k))+
     *        c1*(u(1,i-2,j+1,k)-u(1,i-2,j-1,k))     )
     *     ) +
     *   c1*(  mu(i+1,j,k)*met(1,i+1,j,k)*met(1,i+1,j,k)*(
     *          c2*(u(1,i+1,j+2,k)-u(1,i+1,j-2,k)) +
     *          c1*(u(1,i+1,j+1,k)-u(1,i+1,j-1,k))  )
     *      - mu(i-1,j,k)*met(1,i-1,j,k)*met(1,i-1,j,k)*(
     *          c2*(u(1,i-1,j+2,k)-u(1,i-1,j-2,k)) + 
     *          c1*(u(1,i-1,j+1,k)-u(1,i-1,j-1,k))))

*** rp - derivatives
         dudrm2 = 0
         dudrm1 = 0
         dudrp1 = 0
         dudrp2 = 0
         dvdrm2 = 0
         dvdrm1 = 0
         dvdrp1 = 0
         dvdrp2 = 0
         dwdrm2 = 0
         dwdrm1 = 0
         dwdrp1 = 0
         dwdrp2 = 0
         do q=1,8
            dudrm2 = dudrm2 + bope(k,q)*u(1,i-2,j,q)
            dvdrm2 = dvdrm2 + bope(k,q)*u(2,i-2,j,q)
            dwdrm2 = dwdrm2 + bope(k,q)*u(3,i-2,j,q)
            dudrm1 = dudrm1 + bope(k,q)*u(1,i-1,j,q)
            dvdrm1 = dvdrm1 + bope(k,q)*u(2,i-1,j,q)
            dwdrm1 = dwdrm1 + bope(k,q)*u(3,i-1,j,q)
            dudrp2 = dudrp2 + bope(k,q)*u(1,i+2,j,q)
            dvdrp2 = dvdrp2 + bope(k,q)*u(2,i+2,j,q)
            dwdrp2 = dwdrp2 + bope(k,q)*u(3,i+2,j,q)
            dudrp1 = dudrp1 + bope(k,q)*u(1,i+1,j,q)
            dvdrp1 = dvdrp1 + bope(k,q)*u(2,i+1,j,q)
            dwdrp1 = dwdrp1 + bope(k,q)*u(3,i+1,j,q)
         enddo

*** rp derivatives (u-eq)
      r1 = r1 + ( c2*(
     *  (2*mu(i+2,j,k)+la(i+2,j,k))*met(2,i+2,j,k)*met(1,i+2,j,k)*
     *                                                 strx(i+2)*dudrp2
     *   + la(i+2,j,k)*met(3,i+2,j,k)*met(1,i+2,j,k)*dvdrp2*stry(j)
     *   + la(i+2,j,k)*met(4,i+2,j,k)*met(1,i+2,j,k)*dwdrp2
     *-((2*mu(i-2,j,k)+la(i-2,j,k))*met(2,i-2,j,k)*met(1,i-2,j,k)*
     *                                                 strx(i-2)*dudrm2
     *   + la(i-2,j,k)*met(3,i-2,j,k)*met(1,i-2,j,k)*dvdrm2*stry(j)
     *   + la(i-2,j,k)*met(4,i-2,j,k)*met(1,i-2,j,k)*dwdrm2 )
     *              ) + c1*(  
     *  (2*mu(i+1,j,k)+la(i+1,j,k))*met(2,i+1,j,k)*met(1,i+1,j,k)*
     *                                                 strx(i+1)*dudrp1
     *   + la(i+1,j,k)*met(3,i+1,j,k)*met(1,i+1,j,k)*dvdrp1*stry(j)
     *   + la(i+1,j,k)*met(4,i+1,j,k)*met(1,i+1,j,k)*dwdrp1 
     *-((2*mu(i-1,j,k)+la(i-1,j,k))*met(2,i-1,j,k)*met(1,i-1,j,k)*
     *                                                 strx(i-1)*dudrm1
     *   + la(i-1,j,k)*met(3,i-1,j,k)*met(1,i-1,j,k)*dvdrm1*stry(j)
     *   + la(i-1,j,k)*met(4,i-1,j,k)*met(1,i-1,j,k)*dwdrm1 ) ) )*istry

*** rp derivatives (v-eq)
      r2 = r2 + c2*(
     *     mu(i+2,j,k)*met(3,i+2,j,k)*met(1,i+2,j,k)*dudrp2
     *  +  mu(i+2,j,k)*met(2,i+2,j,k)*met(1,i+2,j,k)*dvdrp2*
     *                                           strx(i+2)*istry
     *  - (mu(i-2,j,k)*met(3,i-2,j,k)*met(1,i-2,j,k)*dudrm2
     *  +  mu(i-2,j,k)*met(2,i-2,j,k)*met(1,i-2,j,k)*dvdrm2*
     *                                           strx(i-2)*istry )
     *             ) + c1*(  
     *     mu(i+1,j,k)*met(3,i+1,j,k)*met(1,i+1,j,k)*dudrp1
     *  +  mu(i+1,j,k)*met(2,i+1,j,k)*met(1,i+1,j,k)*dvdrp1*
     *                                           strx(i+1)*istry
     *  - (mu(i-1,j,k)*met(3,i-1,j,k)*met(1,i-1,j,k)*dudrm1
     *  +  mu(i-1,j,k)*met(2,i-1,j,k)*met(1,i-1,j,k)*dvdrm1*
     *                                           strx(i-1)*istry )
     *                     )

*** rp derivatives (w-eq)
      r3 = r3 + istry*(c2*(
     *     mu(i+2,j,k)*met(4,i+2,j,k)*met(1,i+2,j,k)*dudrp2
     *  +  mu(i+2,j,k)*met(2,i+2,j,k)*met(1,i+2,j,k)*dwdrp2*strx(i+2)
     *  - (mu(i-2,j,k)*met(4,i-2,j,k)*met(1,i-2,j,k)*dudrm2
     *  +  mu(i-2,j,k)*met(2,i-2,j,k)*met(1,i-2,j,k)*dwdrm2*strx(i-2))
     *             ) + c1*(  
     *     mu(i+1,j,k)*met(4,i+1,j,k)*met(1,i+1,j,k)*dudrp1
     *  +  mu(i+1,j,k)*met(2,i+1,j,k)*met(1,i+1,j,k)*dwdrp1*strx(i+1)
     *  - (mu(i-1,j,k)*met(4,i-1,j,k)*met(1,i-1,j,k)*dudrm1
     *  +  mu(i-1,j,k)*met(2,i-1,j,k)*met(1,i-1,j,k)*dwdrm1*strx(i-1))
     *                     ) )

*** rq - derivatives
         dudrm2 = 0
         dudrm1 = 0
         dudrp1 = 0
         dudrp2 = 0
         dvdrm2 = 0
         dvdrm1 = 0
         dvdrp1 = 0
         dvdrp2 = 0
         dwdrm2 = 0
         dwdrm1 = 0
         dwdrp1 = 0
         dwdrp2 = 0
         do q=1,8
            dudrm2 = dudrm2 + bope(k,q)*u(1,i,j-2,q)
            dvdrm2 = dvdrm2 + bope(k,q)*u(2,i,j-2,q)
            dwdrm2 = dwdrm2 + bope(k,q)*u(3,i,j-2,q)
            dudrm1 = dudrm1 + bope(k,q)*u(1,i,j-1,q)
            dvdrm1 = dvdrm1 + bope(k,q)*u(2,i,j-1,q)
            dwdrm1 = dwdrm1 + bope(k,q)*u(3,i,j-1,q)
            dudrp2 = dudrp2 + bope(k,q)*u(1,i,j+2,q)
            dvdrp2 = dvdrp2 + bope(k,q)*u(2,i,j+2,q)
            dwdrp2 = dwdrp2 + bope(k,q)*u(3,i,j+2,q)
            dudrp1 = dudrp1 + bope(k,q)*u(1,i,j+1,q)
            dvdrp1 = dvdrp1 + bope(k,q)*u(2,i,j+1,q)
            dwdrp1 = dwdrp1 + bope(k,q)*u(3,i,j+1,q)
         enddo

*** rq derivatives (u-eq)
      r1 = r1 + c2*(
     *      mu(i,j+2,k)*met(3,i,j+2,k)*met(1,i,j+2,k)*dudrp2*
     *                                           stry(j+2)*istrx
     *   +  mu(i,j+2,k)*met(2,i,j+2,k)*met(1,i,j+2,k)*dvdrp2
     *   - (mu(i,j-2,k)*met(3,i,j-2,k)*met(1,i,j-2,k)*dudrm2*
     *                                           stry(j-2)*istrx
     *   +  mu(i,j-2,k)*met(2,i,j-2,k)*met(1,i,j-2,k)*dvdrm2)
     *             ) + c1*(  
     *      mu(i,j+1,k)*met(3,i,j+1,k)*met(1,i,j+1,k)*dudrp1*
     *                                           stry(j+1)*istrx
     *   +  mu(i,j+1,k)*met(2,i,j+1,k)*met(1,i,j+1,k)*dvdrp1
     *   - (mu(i,j-1,k)*met(3,i,j-1,k)*met(1,i,j-1,k)*dudrm1*
     *                                           stry(j-1)*istrx
     *   +  mu(i,j-1,k)*met(2,i,j-1,k)*met(1,i,j-1,k)*dvdrm1)
     *         )

*** rq derivatives (v-eq)
      r2 = r2 + c2*(
     *      la(i,j+2,k)*met(2,i,j+2,k)*met(1,i,j+2,k)*dudrp2
     * +(2*mu(i,j+2,k)+la(i,j+2,k))*met(3,i,j+2,k)*met(1,i,j+2,k)*dvdrp2
     *                                              *stry(j+2)*istrx
     *    + la(i,j+2,k)*met(4,i,j+2,k)*met(1,i,j+2,k)*dwdrp2*istrx
     *  - ( la(i,j-2,k)*met(2,i,j-2,k)*met(1,i,j-2,k)*dudrm2
     * +(2*mu(i,j-2,k)+la(i,j-2,k))*met(3,i,j-2,k)*met(1,i,j-2,k)*dvdrm2
     *                                              *stry(j-2)*istrx
     *    + la(i,j-2,k)*met(4,i,j-2,k)*met(1,i,j-2,k)*dwdrm2*istrx )
     *             ) + c1*(  
     *      la(i,j+1,k)*met(2,i,j+1,k)*met(1,i,j+1,k)*dudrp1
     * +(2*mu(i,j+1,k)+la(i,j+1,k))*met(3,i,j+1,k)*met(1,i,j+1,k)*dvdrp1
     *                                              *stry(j+1)*istrx
     *    + la(i,j+1,k)*met(4,i,j+1,k)*met(1,i,j+1,k)*dwdrp1*istrx
     *  - ( la(i,j-1,k)*met(2,i,j-1,k)*met(1,i,j-1,k)*dudrm1
     * +(2*mu(i,j-1,k)+la(i,j-1,k))*met(3,i,j-1,k)*met(1,i,j-1,k)*dvdrm1
     *                                              *stry(j-1)*istrx
     *    + la(i,j-1,k)*met(4,i,j-1,k)*met(1,i,j-1,k)*dwdrm1*istrx )
     *        )

*** rq derivatives (w-eq)
      r3 = r3 + ( c2*(
     *     mu(i,j+2,k)*met(3,i,j+2,k)*met(1,i,j+2,k)*dwdrp2*stry(j+2)
     *  +  mu(i,j+2,k)*met(4,i,j+2,k)*met(1,i,j+2,k)*dvdrp2
     *  - (mu(i,j-2,k)*met(3,i,j-2,k)*met(1,i,j-2,k)*dwdrm2*stry(j-2)
     *  +  mu(i,j-2,k)*met(4,i,j-2,k)*met(1,i,j-2,k)*dvdrm2)
     *             ) + c1*(  
     *     mu(i,j+1,k)*met(3,i,j+1,k)*met(1,i,j+1,k)*dwdrp1*stry(j+1)
     *  +  mu(i,j+1,k)*met(4,i,j+1,k)*met(1,i,j+1,k)*dvdrp1
     *  - (mu(i,j-1,k)*met(3,i,j-1,k)*met(1,i,j-1,k)*dwdrm1*stry(j-1)
     *  +  mu(i,j-1,k)*met(4,i,j-1,k)*met(1,i,j-1,k)*dvdrm1)
     *               ) )*istrx

*** pr and qr derivatives at once
      do q=1,8
*** (u-eq)
        r1 = r1 + bope(k,q)*( 
*** pr
     *   (2*mu(i,j,q)+la(i,j,q))*met(2,i,j,q)*met(1,i,j,q)*(
     *          c2*(u(1,i+2,j,q)-u(1,i-2,j,q)) +
     *          c1*(u(1,i+1,j,q)-u(1,i-1,j,q))   )*strx(i)*istry
     *  + mu(i,j,q)*met(3,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(2,i+2,j,q)-u(2,i-2,j,q)) +
     *        c1*(u(2,i+1,j,q)-u(2,i-1,j,q))  ) 
     *  + mu(i,j,q)*met(4,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(3,i+2,j,q)-u(3,i-2,j,q)) +
     *        c1*(u(3,i+1,j,q)-u(3,i-1,j,q))  )*istry 
*** qr
     *  + mu(i,j,q)*met(3,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(1,i,j+2,q)-u(1,i,j-2,q)) +
     *        c1*(u(1,i,j+1,q)-u(1,i,j-1,q))   )*stry(j)*istrx
     *  + la(i,j,q)*met(2,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(2,i,j+2,q)-u(2,i,j-2,q)) +
     *        c1*(u(2,i,j+1,q)-u(2,i,j-1,q))  ) )

*** (v-eq)
        r2 = r2 + bope(k,q)*(
*** pr
     *    la(i,j,q)*met(3,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(1,i+2,j,q)-u(1,i-2,j,q)) +
     *        c1*(u(1,i+1,j,q)-u(1,i-1,j,q))   ) 
     *  + mu(i,j,q)*met(2,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(2,i+2,j,q)-u(2,i-2,j,q)) +
     *        c1*(u(2,i+1,j,q)-u(2,i-1,j,q))  )*strx(i)*istry 
*** qr
     *  + mu(i,j,q)*met(2,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(1,i,j+2,q)-u(1,i,j-2,q)) +
     *        c1*(u(1,i,j+1,q)-u(1,i,j-1,q))   ) 
     * + (2*mu(i,j,q)+la(i,j,q))*met(3,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(2,i,j+2,q)-u(2,i,j-2,q)) +
     *        c1*(u(2,i,j+1,q)-u(2,i,j-1,q))  )*stry(j)*istrx 
     *  + mu(i,j,q)*met(4,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(3,i,j+2,q)-u(3,i,j-2,q)) +
     *        c1*(u(3,i,j+1,q)-u(3,i,j-1,q))   )*istrx  )

*** (w-eq)
        r3 = r3 + bope(k,q)*(
*** pr
     *    la(i,j,q)*met(4,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(1,i+2,j,q)-u(1,i-2,j,q)) +
     *        c1*(u(1,i+1,j,q)-u(1,i-1,j,q))   )*istry 
     *  + mu(i,j,q)*met(2,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(3,i+2,j,q)-u(3,i-2,j,q)) +
     *        c1*(u(3,i+1,j,q)-u(3,i-1,j,q))  )*strx(i)*istry
*** qr 
     *  + mu(i,j,q)*met(3,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(3,i,j+2,q)-u(3,i,j-2,q)) +
     *        c1*(u(3,i,j+1,q)-u(3,i,j-1,q))   )*stry(j)*istrx 
     *  + la(i,j,q)*met(4,i,j,q)*met(1,i,j,q)*(
     *        c2*(u(2,i,j+2,q)-u(2,i,j-2,q)) +
     *        c1*(u(2,i,j+1,q)-u(2,i,j-1,q))  )*istrx )

      enddo
c          lu(1,i,j,k) = r1*ijac
          lu(1,i,j,k) = a1*lu(1,i,j,k) + sgn*r1*ijac
c          lu(2,i,j,k) = r2*ijac
          lu(2,i,j,k) = a1*lu(2,i,j,k) + sgn*r2*ijac
c          lu(3,i,j,k) = r3*ijac
          lu(3,i,j,k) = a1*lu(3,i,j,k) + sgn*r3*ijac
               enddo
            enddo
         enddo
      endif

      do k=kstart,klast-2
         do j=jfirst+2,jlast-2
            do i=ifirst+2,ilast-2
               ijac = strx(i)*stry(j)/jac(i,j,k)
               istry = 1/(stry(j))
               istrx = 1/(strx(i))
               istrxy = istry*istrx

               r1 = 0

*** pp derivative (u)
          cof1=(2*mu(i-2,j,k)+la(i-2,j,k))*met(1,i-2,j,k)*met(1,i-2,j,k)
     *                                              *strx(i-2)
          cof2=(2*mu(i-1,j,k)+la(i-1,j,k))*met(1,i-1,j,k)*met(1,i-1,j,k)
     *                                              *strx(i-1)
          cof3=(2*mu(i,j,k)+la(i,j,k))*met(1,i,j,k)*met(1,i,j,k)
     *                                              *strx(i)
          cof4=(2*mu(i+1,j,k)+la(i+1,j,k))*met(1,i+1,j,k)*met(1,i+1,j,k)
     *                                              *strx(i+1)
          cof5=(2*mu(i+2,j,k)+la(i+2,j,k))*met(1,i+2,j,k)*met(1,i+2,j,k)
     *                                              *strx(i+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i-2,j,k)-u(1,i,j,k)) + 
     *               mux2*(u(1,i-1,j,k)-u(1,i,j,k)) + 
     *               mux3*(u(1,i+1,j,k)-u(1,i,j,k)) +
     *               mux4*(u(1,i+2,j,k)-u(1,i,j,k))  )*istry
*** qq derivative (u)
          cof1=(mu(i,j-2,k))*met(1,i,j-2,k)*met(1,i,j-2,k)*stry(j-2)
          cof2=(mu(i,j-1,k))*met(1,i,j-1,k)*met(1,i,j-1,k)*stry(j-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*stry(j)
          cof4=(mu(i,j+1,k))*met(1,i,j+1,k)*met(1,i,j+1,k)*stry(j+1)
          cof5=(mu(i,j+2,k))*met(1,i,j+2,k)*met(1,i,j+2,k)*stry(j+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i,j-2,k)-u(1,i,j,k)) + 
     *               mux2*(u(1,i,j-1,k)-u(1,i,j,k)) + 
     *               mux3*(u(1,i,j+1,k)-u(1,i,j,k)) +
     *               mux4*(u(1,i,j+2,k)-u(1,i,j,k))  )*istrx
*** rr derivative (u)
          cof1 = (2*mu(i,j,k-2)+la(i,j,k-2))*(met(2,i,j,k-2)*strx(i))**2
     *   +   mu(i,j,k-2)*((met(3,i,j,k-2)*stry(j))**2+met(4,i,j,k-2)**2)
          cof2 = (2*mu(i,j,k-1)+la(i,j,k-1))*(met(2,i,j,k-1)*strx(i))**2
     *   +   mu(i,j,k-1)*((met(3,i,j,k-1)*stry(j))**2+met(4,i,j,k-1)**2)
          cof3 = (2*mu(i,j,k)+la(i,j,k))*(met(2,i,j,k)*strx(i))**2 +
     *         mu(i,j,k)*((met(3,i,j,k)*stry(j))**2+met(4,i,j,k)**2)
          cof4 = (2*mu(i,j,k+1)+la(i,j,k+1))*(met(2,i,j,k+1)*strx(i))**2
     *   +   mu(i,j,k+1)*((met(3,i,j,k+1)*stry(j))**2+met(4,i,j,k+1)**2)
          cof5 = (2*mu(i,j,k+2)+la(i,j,k+2))*(met(2,i,j,k+2)*strx(i))**2
     *   +   mu(i,j,k+2)*((met(3,i,j,k+2)*stry(j))**2+met(4,i,j,k+2)**2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i,j,k-2)-u(1,i,j,k)) + 
     *               mux2*(u(1,i,j,k-1)-u(1,i,j,k)) + 
     *               mux3*(u(1,i,j,k+1)-u(1,i,j,k)) +
     *               mux4*(u(1,i,j,k+2)-u(1,i,j,k))  )*istrxy

*** rr derivative (v)
          cof1=(mu(i,j,k-2)+la(i,j,k-2))*met(2,i,j,k-2)*met(3,i,j,k-2)
          cof2=(mu(i,j,k-1)+la(i,j,k-1))*met(2,i,j,k-1)*met(3,i,j,k-1)
          cof3=(mu(i,j,k)+la(i,j,k))*met(2,i,j,k)*met(3,i,j,k)
          cof4=(mu(i,j,k+1)+la(i,j,k+1))*met(2,i,j,k+1)*met(3,i,j,k+1)
          cof5=(mu(i,j,k+2)+la(i,j,k+2))*met(2,i,j,k+2)*met(3,i,j,k+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(2,i,j,k-2)-u(2,i,j,k)) + 
     *               mux2*(u(2,i,j,k-1)-u(2,i,j,k)) + 
     *               mux3*(u(2,i,j,k+1)-u(2,i,j,k)) +
     *               mux4*(u(2,i,j,k+2)-u(2,i,j,k))  )

*** rr derivative (w)
          cof1=(mu(i,j,k-2)+la(i,j,k-2))*met(2,i,j,k-2)*met(4,i,j,k-2)
          cof2=(mu(i,j,k-1)+la(i,j,k-1))*met(2,i,j,k-1)*met(4,i,j,k-1)
          cof3=(mu(i,j,k)+la(i,j,k))*met(2,i,j,k)*met(4,i,j,k)
          cof4=(mu(i,j,k+1)+la(i,j,k+1))*met(2,i,j,k+1)*met(4,i,j,k+1)
          cof5=(mu(i,j,k+2)+la(i,j,k+2))*met(2,i,j,k+2)*met(4,i,j,k+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(3,i,j,k-2)-u(3,i,j,k)) + 
     *               mux2*(u(3,i,j,k-1)-u(3,i,j,k)) + 
     *               mux3*(u(3,i,j,k+1)-u(3,i,j,k)) +
     *               mux4*(u(3,i,j,k+2)-u(3,i,j,k))  )*istry

*** pq-derivatives
      r1 = r1 + 
     *   c2*(  mu(i,j+2,k)*met(1,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(2,i+2,j+2,k)-u(2,i-2,j+2,k)) +
     *        c1*(u(2,i+1,j+2,k)-u(2,i-1,j+2,k))    )
     *     - mu(i,j-2,k)*met(1,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(2,i+2,j-2,k)-u(2,i-2,j-2,k))+
     *        c1*(u(2,i+1,j-2,k)-u(2,i-1,j-2,k))     )
     *     ) +
     *   c1*(  mu(i,j+1,k)*met(1,i,j+1,k)*met(1,i,j+1,k)*(
     *          c2*(u(2,i+2,j+1,k)-u(2,i-2,j+1,k)) +
     *          c1*(u(2,i+1,j+1,k)-u(2,i-1,j+1,k))  )
     *      - mu(i,j-1,k)*met(1,i,j-1,k)*met(1,i,j-1,k)*(
     *          c2*(u(2,i+2,j-1,k)-u(2,i-2,j-1,k)) + 
     *          c1*(u(2,i+1,j-1,k)-u(2,i-1,j-1,k))))

*** qp-derivatives
      r1 = r1 + 
     *   c2*(  la(i+2,j,k)*met(1,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(2,i+2,j+2,k)-u(2,i+2,j-2,k)) +
     *        c1*(u(2,i+2,j+1,k)-u(2,i+2,j-1,k))    )
     *     - la(i-2,j,k)*met(1,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(2,i-2,j+2,k)-u(2,i-2,j-2,k))+
     *        c1*(u(2,i-2,j+1,k)-u(2,i-2,j-1,k))     )
     *     ) +
     *   c1*(  la(i+1,j,k)*met(1,i+1,j,k)*met(1,i+1,j,k)*(
     *          c2*(u(2,i+1,j+2,k)-u(2,i+1,j-2,k)) +
     *          c1*(u(2,i+1,j+1,k)-u(2,i+1,j-1,k))  )
     *      - la(i-1,j,k)*met(1,i-1,j,k)*met(1,i-1,j,k)*(
     *          c2*(u(2,i-1,j+2,k)-u(2,i-1,j-2,k)) + 
     *          c1*(u(2,i-1,j+1,k)-u(2,i-1,j-1,k))))

*** pr-derivatives
      r1 = r1 + c2*(
     *  (2*mu(i,j,k+2)+la(i,j,k+2))*met(2,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(1,i+2,j,k+2)-u(1,i-2,j,k+2)) +
     *        c1*(u(1,i+1,j,k+2)-u(1,i-1,j,k+2))   )*strx(i)*istry 
     *   + mu(i,j,k+2)*met(3,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(2,i+2,j,k+2)-u(2,i-2,j,k+2)) +
     *        c1*(u(2,i+1,j,k+2)-u(2,i-1,j,k+2))  ) 
     *   + mu(i,j,k+2)*met(4,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(3,i+2,j,k+2)-u(3,i-2,j,k+2)) +
     *        c1*(u(3,i+1,j,k+2)-u(3,i-1,j,k+2))  )*istry
     *  - ((2*mu(i,j,k-2)+la(i,j,k-2))*met(2,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(1,i+2,j,k-2)-u(1,i-2,j,k-2)) +
     *        c1*(u(1,i+1,j,k-2)-u(1,i-1,j,k-2))  )*strx(i)*istry  
     *     + mu(i,j,k-2)*met(3,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(2,i+2,j,k-2)-u(2,i-2,j,k-2)) +
     *        c1*(u(2,i+1,j,k-2)-u(2,i-1,j,k-2))   ) 
     *     + mu(i,j,k-2)*met(4,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(3,i+2,j,k-2)-u(3,i-2,j,k-2)) +
     *        c1*(u(3,i+1,j,k-2)-u(3,i-1,j,k-2))   )*istry )
     *             ) + c1*(  
     *     (2*mu(i,j,k+1)+la(i,j,k+1))*met(2,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(1,i+2,j,k+1)-u(1,i-2,j,k+1)) +
     *        c1*(u(1,i+1,j,k+1)-u(1,i-1,j,k+1)) )*strx(i)*istry 
     *     + mu(i,j,k+1)*met(3,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(2,i+2,j,k+1)-u(2,i-2,j,k+1)) +
     *        c1*(u(2,i+1,j,k+1)-u(2,i-1,j,k+1)) ) 
     *     + mu(i,j,k+1)*met(4,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(3,i+2,j,k+1)-u(3,i-2,j,k+1)) +
     *        c1*(u(3,i+1,j,k+1)-u(3,i-1,j,k+1))  )*istry
     *  - ((2*mu(i,j,k-1)+la(i,j,k-1))*met(2,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(1,i+2,j,k-1)-u(1,i-2,j,k-1)) +
     *        c1*(u(1,i+1,j,k-1)-u(1,i-1,j,k-1)) )*strx(i)*istry  
     *     + mu(i,j,k-1)*met(3,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(2,i+2,j,k-1)-u(2,i-2,j,k-1)) +
     *        c1*(u(2,i+1,j,k-1)-u(2,i-1,j,k-1)) ) 
     *     + mu(i,j,k-1)*met(4,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(3,i+2,j,k-1)-u(3,i-2,j,k-1)) +
     *        c1*(u(3,i+1,j,k-1)-u(3,i-1,j,k-1))   )*istry  ) )

*** rp derivatives
      r1 = r1 +( c2*(
     *  (2*mu(i+2,j,k)+la(i+2,j,k))*met(2,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(1,i+2,j,k+2)-u(1,i+2,j,k-2)) +
     *        c1*(u(1,i+2,j,k+1)-u(1,i+2,j,k-1))   )*strx(i+2) 
     *   + la(i+2,j,k)*met(3,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(2,i+2,j,k+2)-u(2,i+2,j,k-2)) +
     *        c1*(u(2,i+2,j,k+1)-u(2,i+2,j,k-1))  )*stry(j) 
     *   + la(i+2,j,k)*met(4,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(3,i+2,j,k+2)-u(3,i+2,j,k-2)) +
     *        c1*(u(3,i+2,j,k+1)-u(3,i+2,j,k-1))  )
     *  - ((2*mu(i-2,j,k)+la(i-2,j,k))*met(2,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(1,i-2,j,k+2)-u(1,i-2,j,k-2)) +
     *        c1*(u(1,i-2,j,k+1)-u(1,i-2,j,k-1))  )*strx(i-2) 
     *     + la(i-2,j,k)*met(3,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(2,i-2,j,k+2)-u(2,i-2,j,k-2)) +
     *        c1*(u(2,i-2,j,k+1)-u(2,i-2,j,k-1))   )*stry(j) 
     *     + la(i-2,j,k)*met(4,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(3,i-2,j,k+2)-u(3,i-2,j,k-2)) +
     *        c1*(u(3,i-2,j,k+1)-u(3,i-2,j,k-1))   ) )
     *             ) + c1*(  
     *     (2*mu(i+1,j,k)+la(i+1,j,k))*met(2,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(1,i+1,j,k+2)-u(1,i+1,j,k-2)) +
     *        c1*(u(1,i+1,j,k+1)-u(1,i+1,j,k-1)) )*strx(i+1) 
     *     + la(i+1,j,k)*met(3,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(2,i+1,j,k+2)-u(2,i+1,j,k-2)) +
     *        c1*(u(2,i+1,j,k+1)-u(2,i+1,j,k-1)) )*stry(j) 
     *     + la(i+1,j,k)*met(4,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(3,i+1,j,k+2)-u(3,i+1,j,k-2)) +
     *        c1*(u(3,i+1,j,k+1)-u(3,i+1,j,k-1))  )
     *  - ((2*mu(i-1,j,k)+la(i-1,j,k))*met(2,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(1,i-1,j,k+2)-u(1,i-1,j,k-2)) +
     *        c1*(u(1,i-1,j,k+1)-u(1,i-1,j,k-1)) )*strx(i-1) 
     *     + la(i-1,j,k)*met(3,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(2,i-1,j,k+2)-u(2,i-1,j,k-2)) +
     *        c1*(u(2,i-1,j,k+1)-u(2,i-1,j,k-1)) )*stry(j) 
     *     + la(i-1,j,k)*met(4,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(3,i-1,j,k+2)-u(3,i-1,j,k-2)) +
     *        c1*(u(3,i-1,j,k+1)-u(3,i-1,j,k-1))   )  ) ) )*istry

*** qr derivatives
      r1 = r1 + c2*(
     *    mu(i,j,k+2)*met(3,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(1,i,j+2,k+2)-u(1,i,j-2,k+2)) +
     *        c1*(u(1,i,j+1,k+2)-u(1,i,j-1,k+2))   )*stry(j)*istrx 
     *   + la(i,j,k+2)*met(2,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(2,i,j+2,k+2)-u(2,i,j-2,k+2)) +
     *        c1*(u(2,i,j+1,k+2)-u(2,i,j-1,k+2))  ) 
     *  - ( mu(i,j,k-2)*met(3,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(1,i,j+2,k-2)-u(1,i,j-2,k-2)) +
     *        c1*(u(1,i,j+1,k-2)-u(1,i,j-1,k-2))  )*stry(j)*istrx  
     *     + la(i,j,k-2)*met(2,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(2,i,j+2,k-2)-u(2,i,j-2,k-2)) +
     *        c1*(u(2,i,j+1,k-2)-u(2,i,j-1,k-2))   ) ) 
     *             ) + c1*(  
     *      mu(i,j,k+1)*met(3,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(1,i,j+2,k+1)-u(1,i,j-2,k+1)) +
     *        c1*(u(1,i,j+1,k+1)-u(1,i,j-1,k+1)) )*stry(j)*istrx  
     *     + la(i,j,k+1)*met(2,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(2,i,j+2,k+1)-u(2,i,j-2,k+1)) +
     *        c1*(u(2,i,j+1,k+1)-u(2,i,j-1,k+1)) )  
     *  - ( mu(i,j,k-1)*met(3,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(1,i,j+2,k-1)-u(1,i,j-2,k-1)) +
     *        c1*(u(1,i,j+1,k-1)-u(1,i,j-1,k-1)) )*stry(j)*istrx  
     *     + la(i,j,k-1)*met(2,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(2,i,j+2,k-1)-u(2,i,j-2,k-1)) +
     *        c1*(u(2,i,j+1,k-1)-u(2,i,j-1,k-1)) ) ) )

*** rq derivatives
      r1 = r1 + c2*(
     *    mu(i,j+2,k)*met(3,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(1,i,j+2,k+2)-u(1,i,j+2,k-2)) +
     *        c1*(u(1,i,j+2,k+1)-u(1,i,j+2,k-1))   )*stry(j+2)*istrx 
     *   + mu(i,j+2,k)*met(2,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(2,i,j+2,k+2)-u(2,i,j+2,k-2)) +
     *        c1*(u(2,i,j+2,k+1)-u(2,i,j+2,k-1))  ) 
     *  - ( mu(i,j-2,k)*met(3,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(1,i,j-2,k+2)-u(1,i,j-2,k-2)) +
     *        c1*(u(1,i,j-2,k+1)-u(1,i,j-2,k-1))  )*stry(j-2)*istrx  
     *     + mu(i,j-2,k)*met(2,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(2,i,j-2,k+2)-u(2,i,j-2,k-2)) +
     *        c1*(u(2,i,j-2,k+1)-u(2,i,j-2,k-1))   ) ) 
     *             ) + c1*(  
     *      mu(i,j+1,k)*met(3,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(1,i,j+1,k+2)-u(1,i,j+1,k-2)) +
     *        c1*(u(1,i,j+1,k+1)-u(1,i,j+1,k-1)) )*stry(j+1)*istrx
     *     + mu(i,j+1,k)*met(2,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(2,i,j+1,k+2)-u(2,i,j+1,k-2)) +
     *        c1*(u(2,i,j+1,k+1)-u(2,i,j+1,k-1)) )
     *  - ( mu(i,j-1,k)*met(3,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(1,i,j-1,k+2)-u(1,i,j-1,k-2)) +
     *        c1*(u(1,i,j-1,k+1)-u(1,i,j-1,k-1)) )*stry(j-1)*istrx    
     *     + mu(i,j-1,k)*met(2,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(2,i,j-1,k+2)-u(2,i,j-1,k-2)) +
     *        c1*(u(2,i,j-1,k+1)-u(2,i,j-1,k-1)) ) ) )

c          lu(1,i,j,k) = r1/jac(i,j,k)
c          lu(1,i,j,k) = r1*ijac
          lu(1,i,j,k) = a1*lu(1,i,j,k) + sgn*r1*ijac
*** v-equation

          r1 = 0
*** pp derivative (v)
          cof1=(mu(i-2,j,k))*met(1,i-2,j,k)*met(1,i-2,j,k)*strx(i-2)
          cof2=(mu(i-1,j,k))*met(1,i-1,j,k)*met(1,i-1,j,k)*strx(i-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*strx(i)
          cof4=(mu(i+1,j,k))*met(1,i+1,j,k)*met(1,i+1,j,k)*strx(i+1)
          cof5=(mu(i+2,j,k))*met(1,i+2,j,k)*met(1,i+2,j,k)*strx(i+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(2,i-2,j,k)-u(2,i,j,k)) + 
     *               mux2*(u(2,i-1,j,k)-u(2,i,j,k)) + 
     *               mux3*(u(2,i+1,j,k)-u(2,i,j,k)) +
     *               mux4*(u(2,i+2,j,k)-u(2,i,j,k))  )*istry
*** qq derivative (v)
          cof1=(2*mu(i,j-2,k)+la(i,j-2,k))*met(1,i,j-2,k)*met(1,i,j-2,k)
     *                                                     *stry(j-2)
          cof2=(2*mu(i,j-1,k)+la(i,j-1,k))*met(1,i,j-1,k)*met(1,i,j-1,k)
     *                                                     *stry(j-1)
          cof3=(2*mu(i,j,k)+la(i,j,k))*met(1,i,j,k)*met(1,i,j,k)
     *                                                     *stry(j)
          cof4=(2*mu(i,j+1,k)+la(i,j+1,k))*met(1,i,j+1,k)*met(1,i,j+1,k)
     *                                                     *stry(j+1)
          cof5=(2*mu(i,j+2,k)+la(i,j+2,k))*met(1,i,j+2,k)*met(1,i,j+2,k)
     *                                                     *stry(j+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(2,i,j-2,k)-u(2,i,j,k)) + 
     *               mux2*(u(2,i,j-1,k)-u(2,i,j,k)) + 
     *               mux3*(u(2,i,j+1,k)-u(2,i,j,k)) +
     *               mux4*(u(2,i,j+2,k)-u(2,i,j,k))  )*istrx

*** rr derivative (u)
          cof1=(mu(i,j,k-2)+la(i,j,k-2))*met(2,i,j,k-2)*met(3,i,j,k-2)
          cof2=(mu(i,j,k-1)+la(i,j,k-1))*met(2,i,j,k-1)*met(3,i,j,k-1)
          cof3=(mu(i,j,k)+  la(i,j,k)  )*met(2,i,j,k)*  met(3,i,j,k)
          cof4=(mu(i,j,k+1)+la(i,j,k+1))*met(2,i,j,k+1)*met(3,i,j,k+1)
          cof5=(mu(i,j,k+2)+la(i,j,k+2))*met(2,i,j,k+2)*met(3,i,j,k+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i,j,k-2)-u(1,i,j,k)) + 
     *               mux2*(u(1,i,j,k-1)-u(1,i,j,k)) + 
     *               mux3*(u(1,i,j,k+1)-u(1,i,j,k)) +
     *               mux4*(u(1,i,j,k+2)-u(1,i,j,k))  )

*** rr derivative (v)
          cof1 = (2*mu(i,j,k-2)+la(i,j,k-2))*(met(3,i,j,k-2)*stry(j))**2
     *  +    mu(i,j,k-2)*((met(2,i,j,k-2)*strx(i))**2+met(4,i,j,k-2)**2)
          cof2 = (2*mu(i,j,k-1)+la(i,j,k-1))*(met(3,i,j,k-1)*stry(j))**2
     *  +    mu(i,j,k-1)*((met(2,i,j,k-1)*strx(i))**2+met(4,i,j,k-1)**2)
          cof3 = (2*mu(i,j,k)+la(i,j,k))*(met(3,i,j,k)*stry(j))**2 +
     *       mu(i,j,k)*((met(2,i,j,k)*strx(i))**2+met(4,i,j,k)**2)
          cof4 = (2*mu(i,j,k+1)+la(i,j,k+1))*(met(3,i,j,k+1)*stry(j))**2
     *  +    mu(i,j,k+1)*((met(2,i,j,k+1)*strx(i))**2+met(4,i,j,k+1)**2)
          cof5 = (2*mu(i,j,k+2)+la(i,j,k+2))*(met(3,i,j,k+2)*stry(j))**2
     *  +    mu(i,j,k+2)*((met(2,i,j,k+2)*strx(i))**2+met(4,i,j,k+2)**2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(2,i,j,k-2)-u(2,i,j,k)) + 
     *               mux2*(u(2,i,j,k-1)-u(2,i,j,k)) + 
     *               mux3*(u(2,i,j,k+1)-u(2,i,j,k)) +
     *               mux4*(u(2,i,j,k+2)-u(2,i,j,k))  )*istrxy

*** rr derivative (w)
          cof1=(mu(i,j,k-2)+la(i,j,k-2))*met(3,i,j,k-2)*met(4,i,j,k-2)
          cof2=(mu(i,j,k-1)+la(i,j,k-1))*met(3,i,j,k-1)*met(4,i,j,k-1)
          cof3=(mu(i,j,k)  +la(i,j,k)  )*met(3,i,j,k)*  met(4,i,j,k)
          cof4=(mu(i,j,k+1)+la(i,j,k+1))*met(3,i,j,k+1)*met(4,i,j,k+1)
          cof5=(mu(i,j,k+2)+la(i,j,k+2))*met(3,i,j,k+2)*met(4,i,j,k+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(3,i,j,k-2)-u(3,i,j,k)) + 
     *               mux2*(u(3,i,j,k-1)-u(3,i,j,k)) + 
     *               mux3*(u(3,i,j,k+1)-u(3,i,j,k)) +
     *               mux4*(u(3,i,j,k+2)-u(3,i,j,k))  )*istrx

*** pq-derivatives
      r1 = r1 + 
     *   c2*(  la(i,j+2,k)*met(1,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(1,i+2,j+2,k)-u(1,i-2,j+2,k)) +
     *        c1*(u(1,i+1,j+2,k)-u(1,i-1,j+2,k))    )
     *     - la(i,j-2,k)*met(1,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(1,i+2,j-2,k)-u(1,i-2,j-2,k))+
     *        c1*(u(1,i+1,j-2,k)-u(1,i-1,j-2,k))     )
     *     ) +
     *   c1*(  la(i,j+1,k)*met(1,i,j+1,k)*met(1,i,j+1,k)*(
     *          c2*(u(1,i+2,j+1,k)-u(1,i-2,j+1,k)) +
     *          c1*(u(1,i+1,j+1,k)-u(1,i-1,j+1,k))  )
     *      - la(i,j-1,k)*met(1,i,j-1,k)*met(1,i,j-1,k)*(
     *          c2*(u(1,i+2,j-1,k)-u(1,i-2,j-1,k)) + 
     *          c1*(u(1,i+1,j-1,k)-u(1,i-1,j-1,k))))

*** qp-derivatives
      r1 = r1 + 
     *   c2*(  mu(i+2,j,k)*met(1,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(1,i+2,j+2,k)-u(1,i+2,j-2,k)) +
     *        c1*(u(1,i+2,j+1,k)-u(1,i+2,j-1,k))    )
     *     - mu(i-2,j,k)*met(1,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(1,i-2,j+2,k)-u(1,i-2,j-2,k))+
     *        c1*(u(1,i-2,j+1,k)-u(1,i-2,j-1,k))     )
     *     ) +
     *   c1*(  mu(i+1,j,k)*met(1,i+1,j,k)*met(1,i+1,j,k)*(
     *          c2*(u(1,i+1,j+2,k)-u(1,i+1,j-2,k)) +
     *          c1*(u(1,i+1,j+1,k)-u(1,i+1,j-1,k))  )
     *      - mu(i-1,j,k)*met(1,i-1,j,k)*met(1,i-1,j,k)*(
     *          c2*(u(1,i-1,j+2,k)-u(1,i-1,j-2,k)) + 
     *          c1*(u(1,i-1,j+1,k)-u(1,i-1,j-1,k))))

*** pr-derivatives
      r1 = r1 + c2*(
     *  (la(i,j,k+2))*met(3,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(1,i+2,j,k+2)-u(1,i-2,j,k+2)) +
     *        c1*(u(1,i+1,j,k+2)-u(1,i-1,j,k+2))   ) 
     *   + mu(i,j,k+2)*met(2,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(2,i+2,j,k+2)-u(2,i-2,j,k+2)) +
     *        c1*(u(2,i+1,j,k+2)-u(2,i-1,j,k+2))  )*strx(i)*istry 
     *  - ((la(i,j,k-2))*met(3,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(1,i+2,j,k-2)-u(1,i-2,j,k-2)) +
     *        c1*(u(1,i+1,j,k-2)-u(1,i-1,j,k-2))  ) 
     *     + mu(i,j,k-2)*met(2,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(2,i+2,j,k-2)-u(2,i-2,j,k-2)) +
     *        c1*(u(2,i+1,j,k-2)-u(2,i-1,j,k-2)) )*strx(i)*istry ) 
     *             ) + c1*(  
     *     (la(i,j,k+1))*met(3,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(1,i+2,j,k+1)-u(1,i-2,j,k+1)) +
     *        c1*(u(1,i+1,j,k+1)-u(1,i-1,j,k+1)) ) 
     *     + mu(i,j,k+1)*met(2,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(2,i+2,j,k+1)-u(2,i-2,j,k+1)) +
     *        c1*(u(2,i+1,j,k+1)-u(2,i-1,j,k+1)) )*strx(i)*istry  
     *  - (la(i,j,k-1)*met(3,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(1,i+2,j,k-1)-u(1,i-2,j,k-1)) +
     *        c1*(u(1,i+1,j,k-1)-u(1,i-1,j,k-1)) ) 
     *     + mu(i,j,k-1)*met(2,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(2,i+2,j,k-1)-u(2,i-2,j,k-1)) +
     *        c1*(u(2,i+1,j,k-1)-u(2,i-1,j,k-1)) )*strx(i)*istry  ) )

*** rp derivatives
      r1 = r1 + c2*(
     *  (mu(i+2,j,k))*met(3,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(1,i+2,j,k+2)-u(1,i+2,j,k-2)) +
     *        c1*(u(1,i+2,j,k+1)-u(1,i+2,j,k-1))   ) 
     *   + mu(i+2,j,k)*met(2,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(2,i+2,j,k+2)-u(2,i+2,j,k-2)) +
     *        c1*(u(2,i+2,j,k+1)-u(2,i+2,j,k-1))  )*strx(i+2)*istry 
     *  - (mu(i-2,j,k)*met(3,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(1,i-2,j,k+2)-u(1,i-2,j,k-2)) +
     *        c1*(u(1,i-2,j,k+1)-u(1,i-2,j,k-1))  )
     *     + mu(i-2,j,k)*met(2,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(2,i-2,j,k+2)-u(2,i-2,j,k-2)) +
     *        c1*(u(2,i-2,j,k+1)-u(2,i-2,j,k-1))   )*strx(i-2)*istry )
     *             ) + c1*(  
     *     (mu(i+1,j,k))*met(3,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(1,i+1,j,k+2)-u(1,i+1,j,k-2)) +
     *        c1*(u(1,i+1,j,k+1)-u(1,i+1,j,k-1)) ) 
     *     + mu(i+1,j,k)*met(2,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(2,i+1,j,k+2)-u(2,i+1,j,k-2)) +
     *        c1*(u(2,i+1,j,k+1)-u(2,i+1,j,k-1)) )*strx(i+1)*istry 
     *  - (mu(i-1,j,k)*met(3,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(1,i-1,j,k+2)-u(1,i-1,j,k-2)) +
     *        c1*(u(1,i-1,j,k+1)-u(1,i-1,j,k-1)) ) 
     *     + mu(i-1,j,k)*met(2,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(2,i-1,j,k+2)-u(2,i-1,j,k-2)) +
     *        c1*(u(2,i-1,j,k+1)-u(2,i-1,j,k-1)) )*strx(i-1)*istry  ) )

*** qr derivatives
      r1 = r1 + c2*(
     *    mu(i,j,k+2)*met(2,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(1,i,j+2,k+2)-u(1,i,j-2,k+2)) +
     *        c1*(u(1,i,j+1,k+2)-u(1,i,j-1,k+2))   ) 
     *   + (2*mu(i,j,k+2)+la(i,j,k+2))*met(3,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(2,i,j+2,k+2)-u(2,i,j-2,k+2)) +
     *        c1*(u(2,i,j+1,k+2)-u(2,i,j-1,k+2))  )*stry(j)*istrx 
     *   +mu(i,j,k+2)*met(4,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(3,i,j+2,k+2)-u(3,i,j-2,k+2)) +
     *        c1*(u(3,i,j+1,k+2)-u(3,i,j-1,k+2))   )*istrx 
     *  - ( mu(i,j,k-2)*met(2,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(1,i,j+2,k-2)-u(1,i,j-2,k-2)) +
     *        c1*(u(1,i,j+1,k-2)-u(1,i,j-1,k-2))  ) 
     *    +(2*mu(i,j,k-2)+ la(i,j,k-2))*met(3,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(2,i,j+2,k-2)-u(2,i,j-2,k-2)) +
     *        c1*(u(2,i,j+1,k-2)-u(2,i,j-1,k-2))   )*stry(j)*istrx +
     *       mu(i,j,k-2)*met(4,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(3,i,j+2,k-2)-u(3,i,j-2,k-2)) +
     *        c1*(u(3,i,j+1,k-2)-u(3,i,j-1,k-2))  )*istrx ) 
     *             ) + c1*(  
     *      mu(i,j,k+1)*met(2,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(1,i,j+2,k+1)-u(1,i,j-2,k+1)) +
     *        c1*(u(1,i,j+1,k+1)-u(1,i,j-1,k+1)) ) 
     *    + (2*mu(i,j,k+1)+la(i,j,k+1))*met(3,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(2,i,j+2,k+1)-u(2,i,j-2,k+1)) +
     *        c1*(u(2,i,j+1,k+1)-u(2,i,j-1,k+1)) )*stry(j)*istrx
     *    + mu(i,j,k+1)*met(4,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(3,i,j+2,k+1)-u(3,i,j-2,k+1)) +
     *        c1*(u(3,i,j+1,k+1)-u(3,i,j-1,k+1)) )*istrx   
     *  - ( mu(i,j,k-1)*met(2,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(1,i,j+2,k-1)-u(1,i,j-2,k-1)) +
     *        c1*(u(1,i,j+1,k-1)-u(1,i,j-1,k-1)) ) 
     *    + (2*mu(i,j,k-1)+la(i,j,k-1))*met(3,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(2,i,j+2,k-1)-u(2,i,j-2,k-1)) +
     *        c1*(u(2,i,j+1,k-1)-u(2,i,j-1,k-1)) )*stry(j)*istrx
     *    +  mu(i,j,k-1)*met(4,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(3,i,j+2,k-1)-u(3,i,j-2,k-1)) +
     *        c1*(u(3,i,j+1,k-1)-u(3,i,j-1,k-1)) )*istrx  ) )

*** rq derivatives
      r1 = r1 + c2*(
     *    la(i,j+2,k)*met(2,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(1,i,j+2,k+2)-u(1,i,j+2,k-2)) +
     *        c1*(u(1,i,j+2,k+1)-u(1,i,j+2,k-1))   ) 
     *   +(2*mu(i,j+2,k)+la(i,j+2,k))*met(3,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(2,i,j+2,k+2)-u(2,i,j+2,k-2)) +
     *        c1*(u(2,i,j+2,k+1)-u(2,i,j+2,k-1))  )*stry(j+2)*istrx 
     *    + la(i,j+2,k)*met(4,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(3,i,j+2,k+2)-u(3,i,j+2,k-2)) +
     *        c1*(u(3,i,j+2,k+1)-u(3,i,j+2,k-1))   )*istrx 
     *  - ( la(i,j-2,k)*met(2,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(1,i,j-2,k+2)-u(1,i,j-2,k-2)) +
     *        c1*(u(1,i,j-2,k+1)-u(1,i,j-2,k-1))  ) 
     *     +(2*mu(i,j-2,k)+la(i,j-2,k))*met(3,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(2,i,j-2,k+2)-u(2,i,j-2,k-2)) +
     *        c1*(u(2,i,j-2,k+1)-u(2,i,j-2,k-1))   )*stry(j-2)*istrx 
     *    + la(i,j-2,k)*met(4,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(3,i,j-2,k+2)-u(3,i,j-2,k-2)) +
     *        c1*(u(3,i,j-2,k+1)-u(3,i,j-2,k-1))  )*istrx  ) 
     *             ) + c1*(  
     *      la(i,j+1,k)*met(2,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(1,i,j+1,k+2)-u(1,i,j+1,k-2)) +
     *        c1*(u(1,i,j+1,k+1)-u(1,i,j+1,k-1)) ) 
     *     + (2*mu(i,j+1,k)+la(i,j+1,k))*met(3,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(2,i,j+1,k+2)-u(2,i,j+1,k-2)) +
     *        c1*(u(2,i,j+1,k+1)-u(2,i,j+1,k-1)) )*stry(j+1)*istrx 
     *     +la(i,j+1,k)*met(4,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(3,i,j+1,k+2)-u(3,i,j+1,k-2)) +
     *        c1*(u(3,i,j+1,k+1)-u(3,i,j+1,k-1)) )*istrx   
     *  - ( la(i,j-1,k)*met(2,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(1,i,j-1,k+2)-u(1,i,j-1,k-2)) +
     *        c1*(u(1,i,j-1,k+1)-u(1,i,j-1,k-1)) ) 
     *     + (2*mu(i,j-1,k)+la(i,j-1,k))*met(3,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(2,i,j-1,k+2)-u(2,i,j-1,k-2)) +
     *        c1*(u(2,i,j-1,k+1)-u(2,i,j-1,k-1)) )*stry(j-1)*istrx
     *     + la(i,j-1,k)*met(4,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(3,i,j-1,k+2)-u(3,i,j-1,k-2)) +
     *        c1*(u(3,i,j-1,k+1)-u(3,i,j-1,k-1)) )*istrx   ) )

c          lu(2,i,j,k) = r1/jac(i,j,k)
c          lu(2,i,j,k) = r1*ijac
          lu(2,i,j,k) = a1*lu(2,i,j,k) + sgn*r1*ijac
*** w-equation

          r1 = 0
*** pp derivative (w)
          cof1=(mu(i-2,j,k))*met(1,i-2,j,k)*met(1,i-2,j,k)*strx(i-2)
          cof2=(mu(i-1,j,k))*met(1,i-1,j,k)*met(1,i-1,j,k)*strx(i-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*strx(i)
          cof4=(mu(i+1,j,k))*met(1,i+1,j,k)*met(1,i+1,j,k)*strx(i+1)
          cof5=(mu(i+2,j,k))*met(1,i+2,j,k)*met(1,i+2,j,k)*strx(i+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(3,i-2,j,k)-u(3,i,j,k)) + 
     *               mux2*(u(3,i-1,j,k)-u(3,i,j,k)) + 
     *               mux3*(u(3,i+1,j,k)-u(3,i,j,k)) +
     *               mux4*(u(3,i+2,j,k)-u(3,i,j,k))  )*istry

*** qq derivative (w)
          cof1=(mu(i,j-2,k))*met(1,i,j-2,k)*met(1,i,j-2,k)*stry(j-2)
          cof2=(mu(i,j-1,k))*met(1,i,j-1,k)*met(1,i,j-1,k)*stry(j-1)
          cof3=(mu(i,j,k))*met(1,i,j,k)*met(1,i,j,k)*stry(j)
          cof4=(mu(i,j+1,k))*met(1,i,j+1,k)*met(1,i,j+1,k)*stry(j+1)
          cof5=(mu(i,j+2,k))*met(1,i,j+2,k)*met(1,i,j+2,k)*stry(j+2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(3,i,j-2,k)-u(3,i,j,k)) + 
     *               mux2*(u(3,i,j-1,k)-u(3,i,j,k)) + 
     *               mux3*(u(3,i,j+1,k)-u(3,i,j,k)) +
     *               mux4*(u(3,i,j+2,k)-u(3,i,j,k))  )*istrx
*** rr derivative (u)
          cof1=(mu(i,j,k-2)+la(i,j,k-2))*met(2,i,j,k-2)*met(4,i,j,k-2)
          cof2=(mu(i,j,k-1)+la(i,j,k-1))*met(2,i,j,k-1)*met(4,i,j,k-1)
          cof3=(mu(i,j,k)+la(i,j,k))*met(2,i,j,k)*met(4,i,j,k)
          cof4=(mu(i,j,k+1)+la(i,j,k+1))*met(2,i,j,k+1)*met(4,i,j,k+1)
          cof5=(mu(i,j,k+2)+la(i,j,k+2))*met(2,i,j,k+2)*met(4,i,j,k+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(1,i,j,k-2)-u(1,i,j,k)) + 
     *               mux2*(u(1,i,j,k-1)-u(1,i,j,k)) + 
     *               mux3*(u(1,i,j,k+1)-u(1,i,j,k)) +
     *               mux4*(u(1,i,j,k+2)-u(1,i,j,k))  )*istry

*** rr derivative (v)
          cof1=(mu(i,j,k-2)+la(i,j,k-2))*met(3,i,j,k-2)*met(4,i,j,k-2)
          cof2=(mu(i,j,k-1)+la(i,j,k-1))*met(3,i,j,k-1)*met(4,i,j,k-1)
          cof3=(mu(i,j,k)+la(i,j,k))*met(3,i,j,k)*met(4,i,j,k)
          cof4=(mu(i,j,k+1)+la(i,j,k+1))*met(3,i,j,k+1)*met(4,i,j,k+1)
          cof5=(mu(i,j,k+2)+la(i,j,k+2))*met(3,i,j,k+2)*met(4,i,j,k+2)

            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(2,i,j,k-2)-u(2,i,j,k)) + 
     *               mux2*(u(2,i,j,k-1)-u(2,i,j,k)) + 
     *               mux3*(u(2,i,j,k+1)-u(2,i,j,k)) +
     *               mux4*(u(2,i,j,k+2)-u(2,i,j,k))  )*istrx

*** rr derivative (w)
          cof1 = (2*mu(i,j,k-2)+la(i,j,k-2))*met(4,i,j,k-2)**2 +
     *         mu(i,j,k-2)*((met(2,i,j,k-2)*strx(i))**2+
     *                                 (met(3,i,j,k-2)*stry(j))**2)
          cof2 = (2*mu(i,j,k-1)+la(i,j,k-1))*met(4,i,j,k-1)**2 +
     *         mu(i,j,k-1)*((met(2,i,j,k-1)*strx(i))**2+
     *                                 (met(3,i,j,k-1)*stry(j))**2)
          cof3 = (2*mu(i,j,k)+la(i,j,k))*met(4,i,j,k)**2 +
     *         mu(i,j,k)*((met(2,i,j,k)*strx(i))**2+
     *                                 (met(3,i,j,k)*stry(j))**2)
          cof4 = (2*mu(i,j,k+1)+la(i,j,k+1))*met(4,i,j,k+1)**2 +
     *         mu(i,j,k+1)*((met(2,i,j,k+1)*strx(i))**2+
     *                                 (met(3,i,j,k+1)*stry(j))**2)
          cof5 = (2*mu(i,j,k+2)+la(i,j,k+2))*met(4,i,j,k+2)**2 +
     *         mu(i,j,k+2)*((met(2,i,j,k+2)*strx(i))**2+
     *                                 (met(3,i,j,k+2)*stry(j))**2)
            mux1 = cof2 -tf*(cof3+cof1)
            mux2 = cof1 + cof4+3*(cof3+cof2)
            mux3 = cof2 + cof5+3*(cof4+cof3)
            mux4 = cof4-tf*(cof3+cof5)

            r1 = r1 + i6* (
     *               mux1*(u(3,i,j,k-2)-u(3,i,j,k)) + 
     *               mux2*(u(3,i,j,k-1)-u(3,i,j,k)) + 
     *               mux3*(u(3,i,j,k+1)-u(3,i,j,k)) +
     *               mux4*(u(3,i,j,k+2)-u(3,i,j,k))  )*istrxy

*** pr-derivatives
c      r1 = r1 
     *
     *     + c2*(
     *  (la(i,j,k+2))*met(4,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(1,i+2,j,k+2)-u(1,i-2,j,k+2)) +
     *        c1*(u(1,i+1,j,k+2)-u(1,i-1,j,k+2))   )*istry 
     *   + mu(i,j,k+2)*met(2,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(3,i+2,j,k+2)-u(3,i-2,j,k+2)) +
     *        c1*(u(3,i+1,j,k+2)-u(3,i-1,j,k+2))  )*strx(i)*istry 
     *  - ((la(i,j,k-2))*met(4,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(1,i+2,j,k-2)-u(1,i-2,j,k-2)) +
     *        c1*(u(1,i+1,j,k-2)-u(1,i-1,j,k-2))  )*istry  
     *     + mu(i,j,k-2)*met(2,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(3,i+2,j,k-2)-u(3,i-2,j,k-2)) +
     *        c1*(u(3,i+1,j,k-2)-u(3,i-1,j,k-2)) )*strx(i)*istry ) 
     *             ) + c1*(  
     *     (la(i,j,k+1))*met(4,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(1,i+2,j,k+1)-u(1,i-2,j,k+1)) +
     *        c1*(u(1,i+1,j,k+1)-u(1,i-1,j,k+1)) )*istry  
     *     + mu(i,j,k+1)*met(2,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(3,i+2,j,k+1)-u(3,i-2,j,k+1)) +
     *        c1*(u(3,i+1,j,k+1)-u(3,i-1,j,k+1)) )*strx(i)*istry  
     *  - (la(i,j,k-1)*met(4,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(1,i+2,j,k-1)-u(1,i-2,j,k-1)) +
     *        c1*(u(1,i+1,j,k-1)-u(1,i-1,j,k-1)) )*istry  
     *     + mu(i,j,k-1)*met(2,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(3,i+2,j,k-1)-u(3,i-2,j,k-1)) +
     *        c1*(u(3,i+1,j,k-1)-u(3,i-1,j,k-1)) )*strx(i)*istry  ) )

*** rp derivatives
c      r1 = r1 
     *
     *    + istry*(c2*(
     *  (mu(i+2,j,k))*met(4,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(1,i+2,j,k+2)-u(1,i+2,j,k-2)) +
     *        c1*(u(1,i+2,j,k+1)-u(1,i+2,j,k-1))   ) 
     *   + mu(i+2,j,k)*met(2,i+2,j,k)*met(1,i+2,j,k)*(
     *        c2*(u(3,i+2,j,k+2)-u(3,i+2,j,k-2)) +
     *        c1*(u(3,i+2,j,k+1)-u(3,i+2,j,k-1)) )*strx(i+2) 
     *  - (mu(i-2,j,k)*met(4,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(1,i-2,j,k+2)-u(1,i-2,j,k-2)) +
     *        c1*(u(1,i-2,j,k+1)-u(1,i-2,j,k-1))  )
     *     + mu(i-2,j,k)*met(2,i-2,j,k)*met(1,i-2,j,k)*(
     *        c2*(u(3,i-2,j,k+2)-u(3,i-2,j,k-2)) +
     *        c1*(u(3,i-2,j,k+1)-u(3,i-2,j,k-1)) )*strx(i-2)  )
     *             ) + c1*(  
     *     (mu(i+1,j,k))*met(4,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(1,i+1,j,k+2)-u(1,i+1,j,k-2)) +
     *        c1*(u(1,i+1,j,k+1)-u(1,i+1,j,k-1)) ) 
     *     + mu(i+1,j,k)*met(2,i+1,j,k)*met(1,i+1,j,k)*(
     *        c2*(u(3,i+1,j,k+2)-u(3,i+1,j,k-2)) +
     *        c1*(u(3,i+1,j,k+1)-u(3,i+1,j,k-1)) )*strx(i+1)  
     *  - (mu(i-1,j,k)*met(4,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(1,i-1,j,k+2)-u(1,i-1,j,k-2)) +
     *        c1*(u(1,i-1,j,k+1)-u(1,i-1,j,k-1)) ) 
     *     + mu(i-1,j,k)*met(2,i-1,j,k)*met(1,i-1,j,k)*(
     *        c2*(u(3,i-1,j,k+2)-u(3,i-1,j,k-2)) +
     *        c1*(u(3,i-1,j,k+1)-u(3,i-1,j,k-1)) )*strx(i-1)  ) ) )

*** qr derivatives
     *  
c      r1 = r1
     *    + c2*(
     *    mu(i,j,k+2)*met(3,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(3,i,j+2,k+2)-u(3,i,j-2,k+2)) +
     *        c1*(u(3,i,j+1,k+2)-u(3,i,j-1,k+2))   )*stry(j)*istrx 
     *   + la(i,j,k+2)*met(4,i,j,k+2)*met(1,i,j,k+2)*(
     *        c2*(u(2,i,j+2,k+2)-u(2,i,j-2,k+2)) +
     *        c1*(u(2,i,j+1,k+2)-u(2,i,j-1,k+2))  )*istrx 
     *  - ( mu(i,j,k-2)*met(3,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(3,i,j+2,k-2)-u(3,i,j-2,k-2)) +
     *        c1*(u(3,i,j+1,k-2)-u(3,i,j-1,k-2))  )*stry(j)*istrx  
     *     + la(i,j,k-2)*met(4,i,j,k-2)*met(1,i,j,k-2)*(
     *        c2*(u(2,i,j+2,k-2)-u(2,i,j-2,k-2)) +
     *        c1*(u(2,i,j+1,k-2)-u(2,i,j-1,k-2))   )*istrx  ) 
     *             ) + c1*(  
     *      mu(i,j,k+1)*met(3,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(3,i,j+2,k+1)-u(3,i,j-2,k+1)) +
     *        c1*(u(3,i,j+1,k+1)-u(3,i,j-1,k+1)) )*stry(j)*istrx  
     *     + la(i,j,k+1)*met(4,i,j,k+1)*met(1,i,j,k+1)*(
     *        c2*(u(2,i,j+2,k+1)-u(2,i,j-2,k+1)) +
     *        c1*(u(2,i,j+1,k+1)-u(2,i,j-1,k+1)) )*istrx   
     *  - ( mu(i,j,k-1)*met(3,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(3,i,j+2,k-1)-u(3,i,j-2,k-1)) +
     *        c1*(u(3,i,j+1,k-1)-u(3,i,j-1,k-1)) )*stry(j)*istrx  
     *     + la(i,j,k-1)*met(4,i,j,k-1)*met(1,i,j,k-1)*(
     *        c2*(u(2,i,j+2,k-1)-u(2,i,j-2,k-1)) +
     *        c1*(u(2,i,j+1,k-1)-u(2,i,j-1,k-1)) )*istrx  ) )

*** rq derivatives
     *
c      r1 = r1 
     *     + istrx*(c2*(
     *    mu(i,j+2,k)*met(3,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(3,i,j+2,k+2)-u(3,i,j+2,k-2)) +
     *        c1*(u(3,i,j+2,k+1)-u(3,i,j+2,k-1))   )*stry(j+2) 
     *   + mu(i,j+2,k)*met(4,i,j+2,k)*met(1,i,j+2,k)*(
     *        c2*(u(2,i,j+2,k+2)-u(2,i,j+2,k-2)) +
     *        c1*(u(2,i,j+2,k+1)-u(2,i,j+2,k-1))  ) 
     *  - ( mu(i,j-2,k)*met(3,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(3,i,j-2,k+2)-u(3,i,j-2,k-2)) +
     *        c1*(u(3,i,j-2,k+1)-u(3,i,j-2,k-1))  )*stry(j-2) 
     *     + mu(i,j-2,k)*met(4,i,j-2,k)*met(1,i,j-2,k)*(
     *        c2*(u(2,i,j-2,k+2)-u(2,i,j-2,k-2)) +
     *        c1*(u(2,i,j-2,k+1)-u(2,i,j-2,k-1))   ) ) 
     *             ) + c1*(  
     *      mu(i,j+1,k)*met(3,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(3,i,j+1,k+2)-u(3,i,j+1,k-2)) +
     *        c1*(u(3,i,j+1,k+1)-u(3,i,j+1,k-1)) )*stry(j+1) 
     *     + mu(i,j+1,k)*met(4,i,j+1,k)*met(1,i,j+1,k)*(
     *        c2*(u(2,i,j+1,k+2)-u(2,i,j+1,k-2)) +
     *        c1*(u(2,i,j+1,k+1)-u(2,i,j+1,k-1)) )  
     *  - ( mu(i,j-1,k)*met(3,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(3,i,j-1,k+2)-u(3,i,j-1,k-2)) +
     *        c1*(u(3,i,j-1,k+1)-u(3,i,j-1,k-1)) )*stry(j-1) 
     *     + mu(i,j-1,k)*met(4,i,j-1,k)*met(1,i,j-1,k)*(
     *        c2*(u(2,i,j-1,k+2)-u(2,i,j-1,k-2)) +
     *        c1*(u(2,i,j-1,k+1)-u(2,i,j-1,k-1)) ) ) ) )


c          lu(3,i,j,k) = r1/jac(i,j,k)
c          lu(3,i,j,k) = r1*ijac
          lu(3,i,j,k) = a1*lu(3,i,j,k) + sgn*r1*ijac

      enddo
      enddo
      enddo
      end

