/ * 
 l o a d a r e a s   p e r   m v - g r i d d i s t r i c t 
 i n s e r t   c u t t e d   l o a d   m e l t 
 e x c l u d e   s m a l l e r   1 0 0 m 2 
 
 _ _ c o p y r i g h t _ _   	 =   " R e i n e r   L e m o i n e   I n s t i t u t " 
 _ _ l i c e n s e _ _   	 =   " G N U   A f f e r o   G e n e r a l   P u b l i c   L i c e n s e   V e r s i o n   3   ( A G P L - 3 . 0 ) " 
 _ _ u r l _ _   	 =   " h t t p s : / / g i t h u b . c o m / o p e n e g o / d a t a _ p r o c e s s i n g / b l o b / m a s t e r / L I C E N S E " 
 _ _ a u t h o r _ _   	 =   " L u d e e " 
 * / 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 1 0 ' , ' i n p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ g r i d _ h v m v _ s u b s t a t i o n ' , ' e g o _ d p _ l o a d a r e a _ s t a t i s t i c . s q l ' , '   ' ) ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 1 0 ' , ' i n p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , ' e g o _ d p _ l o a d a r e a _ s t a t i s t i c . s q l ' , '   ' ) ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 1 0 ' , ' i n p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ d e m a n d _ l o a d a r e a ' , ' e g o _ d p _ l o a d a r e a _ s t a t i s t i c . s q l ' , '   ' ) ; 
 
 
 - -   r e s u l t s   a n d   s t a t i s t i c s   f o r   s u b s t a t i o n ,   l o a d   a r e a ,   M V   g r i d   d i s t r i c t s   a n d   c o n s u m p t i o n 
 D R O P   T A B L E   I F   E X I S T S   	 m o d e l _ d r a f t . e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s   C A S C A D E ; 
 C R E A T E   T A B L E   	 	 m o d e l _ d r a f t . e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s   ( 
 	 i d   S E R I A L , 
 	 s c h e m a _ n a m e   t e x t , 
 	 t a b l e _ n a m e   t e x t , 
 	 d e s c r i p t i o n   t e x t , 
 	 r e s u l t   i n t e g e r , 
 	 u n i t   t e x t , 
 	 t i m e s t a m p   t i m e s t a m p , 
 	 C O N S T R A I N T   e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s _ p k e y   P R I M A R Y   K E Y   ( i d ) ) ; 
 
 I N S E R T   I N T O   m o d e l _ d r a f t . e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s   ( s c h e m a _ n a m e , t a b l e _ n a m e , d e s c r i p t i o n , r e s u l t , u n i t , t i m e s t a m p ) 
 	 - -   C o u n t   S U B 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ g r i d _ h v m v _ s u b s t a t i o n ' , 
 	 	 ' N u m b e r   o f   s u b s t a t i o n s ' , 
 	 	 C O U N T ( s u b s t _ i d )   : : i n t e g e r   A S   r e s u l t , 
 	 	 '   '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n 
 	 U N I O N   A L L 
 	 - -   C o u n t   M V G D 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , 
 	 	 ' N u m b e r   o f   g r i d   d i s t r i c t s ' , 
 	 	 C O U N T ( s u b s t _ i d )   : : i n t e g e r   A S   r e s u l t , 
 	 	 '   '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t 
 
 	 U N I O N   A L L 
 	 - -   A r e a   v g 2 5 0 . g e m 
 	 S E L E C T 	 ' p o l i t i c a l _ b o u n d a r y ' , 
 	 	 ' b k g _ v g 2 5 0 _ 6 _ g e m ' , 
 	 	 ' G e m e i n d e   a r e a ' , 
 	 	 S U M ( S T _ A R E A ( S T _ T R A N S F O R M ( g e o m , 3 0 2 5 ) ) / 1 0 0 0 0 )   : : i n t e g e r   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m 
 	 U N I O N   A L L 	 
 	 - -   A r e a   v g 2 5 0 . g e m _ c l e a n 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ p o l i t i c a l _ b o u n d a r y _ b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n ' , 
 	 	 ' P r o c e s s e d   g e m e i n d e   a r e a ' , 
 	 	 S U M ( S T _ A R E A ( S T _ T R A N S F O R M ( g e o m , 3 0 2 5 ) ) / 1 0 0 0 0 )   : : i n t e g e r   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n 
 	 U N I O N   A L L 
 	 - -   A r e a   G D 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , 
 	 	 ' G r i d   D i s t r i c t   a r e a ' , 
 	 	 S U M ( S T _ A R E A ( g e o m ) / 1 0 0 0 0 )   : : i n t e g e r   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t 
 	 U N I O N   A L L 
 	 - -   M i n   a r e a   G D   c a l c 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , 
 	 	 ' M i n m a l   G D   a r e a ' , 
 	 	 M I N ( S T _ A R E A ( g e o m ) / 1 0 0 0 0 )   : : d e c i m a l ( 1 0 , 1 )   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t 
 	 U N I O N   A L L 
 	 - -   M i n   a r e a   G D   a r e a 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , 
 	 	 ' M i n m a l   G D   a r e a ' , 
 	 	 M I N ( a r e a _ h a )   : : d e c i m a l ( 1 0 , 1 )   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t 
 	 U N I O N   A L L 
 	 - -   M a x   a r e a   G D 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , 
 	 	 ' M a x i m a l   G D   a r e a ' , 
 	 	 M A X ( S T _ A R E A ( g e o m ) / 1 0 0 0 0 )   : : d e c i m a l ( 1 0 , 1 )   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t 
 	 U N I O N   A L L 
 	 - -   C o u n t   L A 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ d e m a n d _ l o a d a r e a ' , 
 	 	 ' N u m b e r   o f   L o a d   A r e a s ' , 
 	 	 C O U N T ( i d )   : : i n t e g e r   A S   r e s u l t , 
 	 	 '   '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a 
 	 U N I O N   A L L 
 	 - -   A r e a   L A 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ d e m a n d _ l o a d a r e a ' , 
 	 	 ' L o a d   A r e a s   a r e a ' , 
 	 	 S U M ( S T _ A R E A ( g e o m ) / 1 0 0 0 0 )   : : d e c i m a l ( 1 0 , 1 )   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a 
 
 	 U N I O N   A L L 
 	 - -   M i n   a r e a   L A 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ d e m a n d _ l o a d a r e a ' , 
 	 	 ' M i n m a l   L A   a r e a ' , 
 	 	 M I N ( S T _ A R E A ( g e o m ) / 1 0 0 0 0 )   : : d e c i m a l ( 1 0 , 3 )   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a 
 	 U N I O N   A L L 
 	 - -   M a x   a r e a   L A 
 	 S E L E C T 	 ' m o d e l _ d r a f t ' , 
 	 	 ' e g o _ d e m a n d _ l o a d a r e a ' , 
 	 	 ' M a x i m a l   L A   a r e a ' , 
 	 	 M A X ( S T _ A R E A ( g e o m ) / 1 0 0 0 0 )   : : d e c i m a l ( 1 0 , 3 )   A S   r e s u l t , 
 	 	 ' h a '   : : t e x t   A S   u n i t , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n ' 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a ; 
 
 - -   S e t   g r a n t s   a n d   o w n e r 
 A L T E R   T A B L E   m o d e l _ d r a f t . e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s   O W N E R   T O   o e u s e r ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 1 0 ' , ' o u t p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s ' , ' e g o _ d p _ l o a d a r e a _ s t a t i s t i c . s q l ' , '   ' ) ; 
 
 
 
 / *   - -   m v - g r i d d i s t r i c t   t y p e s 
 D R O P   T A B L E   I F   E X I S T S   	 m o d e l _ d r a f t . e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s _ m v g d   C A S C A D E ; 
 C R E A T E   T A B L E 	 	 m o d e l _ d r a f t . e g o _ d a t a _ p r o c e s s i n g _ r e s u l t s _ m v g d   A S 
 	 S E L E C T 	 s u b s t _ i d , 
 	 	 ' 0 '   : : i n t e g e r   A S   t y p e 1 , 
 	 	 ' 0 '   : : i n t e g e r   A S   t y p e 1 _ c n t , 
 	 	 ' 0 '   : : i n t e g e r   A S   t y p e 2 , 
 	 	 ' 0 '   : : i n t e g e r   A S   t y p e 2 _ c n t , 
 	 	 ' 0 '   : : i n t e g e r   A S   t y p e 3 , 
 	 	 ' 0 '   : : i n t e g e r   A S   t y p e 3 _ c n t , 
 	 	 ' 0 '   : : c h a r ( 1 )   A S   " g r o u p " , 
 	 	 ' 0 '   : : i n t e g e r   A S   g e m , 
 	 	 ' 0 '   : : i n t e g e r   A S   g e m _ c l e a n , 
 	 	 ' 0 '   : : i n t e g e r   A S   l a _ c o u n t , 
 	 	 ' 0 '   : : d e c i m a l ( 1 0 , 1 )   A S   a r e a _ h a , 	 
 	 	 ' 0 '   : : d e c i m a l ( 1 0 , 1 )   A S   l a _ a r e a , 
 	 	 ' 0 '   : : d e c i m a l ( 1 0 , 1 )   A S   f r e e _ a r e a , 
 	 	 ' 0 '   : : d e c i m a l ( 4 , 1 )   A S   a r e a _ s h a r e , 
 	 	 ' 0 '   : : n u m e r i c   A S   c o n s u m p t i o n , 
 	 	 ' 0 '   : : n u m e r i c   A S   c o n s u m p t i o n _ p e r _ a r e a , 
 	 	 g e o m , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n '   A S   t i m e s t a m p 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d ; 
   * / 
 - -   T y p e 1 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 t y p e 1   =   t 2 . t y p e 1 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) : : i n t e g e r   A S   t y p e 1 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ t y p e 1   A S   t y p , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   t y p . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 t y p e 1 _ c n t   =   t 2 . t y p e _ c n t 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) : : i n t e g e r   A S   t y p e _ c n t 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ h v m v _ s u b s t _ p e r _ g e m _ 1 _ m v i e w   A S   t y p , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   t y p . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 - -   T y p e 2 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 t y p e 2   =   t 2 . t y p e 2 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) : : i n t e g e r   A S   t y p e 2 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ t y p e 2   A S   t y p , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   t y p . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 t y p e 2 _ c n t   =   t 2 . t y p e _ c n t 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) : : i n t e g e r   A S   t y p e _ c n t 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ v o r o n o i _ c u t   A S   t y p , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   t y p . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 
 - -   T y p e 3 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 t y p e 3   =   t 2 . t y p e 3 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) : : i n t e g e r   A S   t y p e 3 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ t y p e 3   A S   t y p , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   t y p . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 t y p e 3 _ c n t   =   t 2 . t y p e _ c n t 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) : : i n t e g e r   A S   t y p e _ c n t 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ h v m v _ s u b s t _ p e r _ g e m _ 3 _ m v i e w   A S   t y p , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   t y p . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( t y p . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 
 - -   G r o u p 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t 
 S E T     	 " g r o u p "   =   ( S E L E C T 	 
 	 	 C A S E 
 	 	 	 W H E N 	 t y p e 1   =   ' 1 '   A N D   t y p e 2   =   ' 0 '   A N D   t y p e 3   =   ' 1 '   T H E N   ' A '   - -   l � n d l i c h 
 	 	 	 W H E N 	 t y p e 1   =   ' 0 '   A N D   t y p e 2   =   ' 1 '   A N D   t y p e 3   =   ' 1 '   T H E N   ' B ' 
 	 	 	 W H E N 	 t y p e 1   =   ' 1 '   A N D   t y p e 2   =   ' 0 '   A N D   t y p e 3   =   ' 0 '   T H E N   ' C ' 
 	 	 	 W H E N 	 t y p e 1   =   ' 0 '   A N D   t y p e 2   =   ' 1 '   A N D   t y p e 3   =   ' 0 '   T H E N   ' D '   - -   s t � d t i s c h 
 	 	 E N D ) ; 
 
 
 D R O P   M A T E R I A L I Z E D   V I E W   I F   E X I S T S   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ p t s ; 
 C R E A T E   M A T E R I A L I Z E D   V I E W   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ p t s   A S 
 S E L E C T 	 i d , 
 	 a g s _ 0 , 
 	 S T _ P o i n t O n S u r f a c e ( g e o m )   A S   g e o m 
 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m ; 
 
 - -   G e m e i n d e n 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 g e m   =   t 2 . g e m 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( g e m . g e o m ) ) : : i n t e g e r   A S   g e m 
 	 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m   A S   g e m , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   S T _ T R A N S F O R M ( g e m . g e o m , 3 0 3 5 )   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( S T _ T R A N S F O R M ( g e m . g e o m , 3 0 3 5 ) ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 / *   - -   b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n _ p t s 
 D R O P   M A T E R I A L I Z E D   V I E W   I F   E X I S T S   m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n _ p t s ; 
 C R E A T E   M A T E R I A L I Z E D   V I E W   m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n _ p t s   A S 
 S E L E C T 	 i d , 
 	 a g s _ 0 , 
 	 S T _ P o i n t O n S u r f a c e ( g e o m )   A S   g e o m 
 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n ;   * / 
 
 - -   G e m e i n d e   P a r t s 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 g e m _ c l e a n   =   t 2 . g e m _ c l e a n 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( g e m . g e o m ) ) : : i n t e g e r   A S   g e m _ c l e a n 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ b k g _ v g 2 5 0 _ 6 _ g e m _ c l e a n   A S   g e m , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   g e m . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( g e m . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 - -   G D   A r e a   3 6 1 0 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 a r e a _ h a   =   t 2 . a r e a _ h a 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 S T _ A R E A ( g d . g e o m ) / 1 0 0 0 0   A S   a r e a _ h a 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 - -   L A   C o u n t 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 l a _ c o u n t   =   t 2 . l a _ c o u n t 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 C O U N T ( S T _ P o i n t O n S u r f a c e ( l a . g e o m ) ) : : i n t e g e r   A S   l a _ c o u n t 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   l a . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( l a . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 - -   L A   A r e a   3 6 0 6 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 l a _ a r e a   =   t 2 . l a _ a r e a 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 S U M ( S T _ A R E A ( l a . g e o m ) / 1 0 0 0 0 )   : : d e c i m a l ( 1 0 , 3 )   A S   l a _ a r e a 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 W H E R E 	 g d . g e o m   & &   l a . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( g d . g e o m , S T _ P o i n t O n S u r f a c e ( l a . g e o m ) ) 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 - -   n o t   L A   A r e a   ( f r e e _ a r e a ) 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 f r e e _ a r e a   =   t 2 . f r e e _ a r e a 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 S U M ( g d . a r e a _ h a ) - S U M ( g d . l a _ a r e a )   A S   f r e e _ a r e a 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   a s   g d 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 - -   n o t   L A   A r e a   ( f r e e _ a r e a ) 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 S E T     	 a r e a _ s h a r e   =   t 2 . a r e a _ s h a r e 
 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 S U M ( g d . l a _ a r e a ) / S U M ( g d . a r e a _ h a ) * 1 0 0   A S   a r e a _ s h a r e 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   a s   g d 
 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 ) A S   t 2 
 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 
 S E L E C T 	 M A X ( a r e a _ s h a r e )   A S   m a x , 
 	 M I N ( a r e a _ s h a r e )   A S   m i n 
 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   ; 
 
 
 - -   C o n s u m p t i o n 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 	 S E T     	 c o n s u m p t i o n   =   t 2 . c o n s u m p t i o n 
 	 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 	 S U M ( l a . s e c t o r _ c o n s u m p t i o n _ s u m ) : : n u m e r i c   A S   c o n s u m p t i o n 
 	 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a , 
 	 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   g d 
 	 	 W H E R E 	 g d . s u b s t _ i d   =   l a . s u b s t _ i d 
 	 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 	 ) A S   t 2 
 	 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ; 
 	 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 	 S E T     	 c o n s u m p t i o n _ p e r _ a r e a   =   c o n s u m p t i o n   * 1 0 0 0 0 0 0   /   a r e a _ h a ; 
 
 - -   t e s t 
 S E L E C T 	 S U M ( m v g d . c o n s u m p t i o n ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   m v g d 
 U N I O N   A L L 
 S E L E C T 	 S U M ( l a . s e c t o r _ c o n s u m p t i o n _ s u m ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a ; 
 	 
 / *   U P D A T E   	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   t 1 
 	 S E T     	 c o n s u m p t i o n _ p e r _ a r e a   =   t 2 . c o n s u m p t i o n _ p e r _ a r e a 
 	 F R O M 	 ( S E L E C T 	 g d . s u b s t _ i d , 
 	 	 	 S U M ( l a . s e c t o r _ c o n s u m p t i o n _ s u m ) : : i n t e g e r   A S   c o n s u m p t i o n 
 	 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   A S   m v g d 
 	 	 W H E R E 	 g d . s u b s t _ i d   =   l a . s u b s t _ i d 
 	 	 G R O U P   B Y   g d . s u b s t _ i d 
 	 	 ) A S   t 2 
 	 W H E R E     	 t 1 . s u b s t _ i d   =   t 2 . s u b s t _ i d ;   * / 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 5 ' , ' o u t p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ g r i d _ m v _ g r i d d i s t r i c t ' , ' e g o _ p a p e r _ r e s u l t . s q l ' , '   ' ) ; 
 
 	 
 
 - -   C a l c u l a t e   s t a t i s t i c s   f o r   B K G - v g 2 5 0   
 D R O P   M A T E R I A L I Z E D   V I E W   I F   E X I S T S   	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ s t a t i s t i c s _ m v i e w   C A S C A D E ; 
 C R E A T E   M A T E R I A L I Z E D   V I E W 	 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ s t a t i s t i c s _ m v i e w   A S   
 - -   C a l c u l a t e   a r e a s 
 S E L E C T 	 ' 1 '   : : i n t e g e r   A S   i d , 
 	 ' 1 _ s t a '   : : t e x t   A S   t a b l e , 
 	 ' v g '   : : t e x t   A S   d e s c r i p t _ n a m e i o n , 
 	 S U M ( v g . a r e a _ h a )   : : i n t e g e r   A S   a r e a _ s u m _ h a 
 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 1 _ s t a _ m v i e w   A S   v g 
 U N I O N   A L L 
 S E L E C T 	 ' 3 '   : : i n t e g e r   A S   i d , 
 	 ' 1 _ s t a '   : : t e x t   A S   t a b l e , 
 	 ' d e u '   : : t e x t   A S   d e s c r i p t _ n a m e i o n , 
 	 S U M ( v g . a r e a _ h a )   : : i n t e g e r   A S   a r e a _ s u m _ h a 
 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 1 _ s t a _ m v i e w   A S   v g 
 W H E R E 	 b e z = ' B u n d e s r e p u b l i k ' 
 U N I O N   A L L 
 S E L E C T 	 ' 4 '   : : i n t e g e r   A S   i d , 
 	 ' 1 _ s t a '   : : t e x t   A S   t a b l e , 
 	 ' N O T   d e u '   : : t e x t   A S   d e s c r i p t _ n a m e i o n , 
 	 S U M ( v g . a r e a _ h a )   : : i n t e g e r   A S   a r e a _ s u m _ h a 
 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 1 _ s t a _ m v i e w   A S   v g 
 W H E R E 	 b e z = ' - - ' 
 U N I O N   A L L 
 S E L E C T 	 ' 5 '   : : i n t e g e r   A S   i d , 
 	 ' 1 _ s t a '   : : t e x t   A S   t a b l e , 
 	 ' l a n d '   : : t e x t   A S   d e s c r i p t _ n a m e i o n , 
 	 S U M ( v g . a r e a _ h a )   : : i n t e g e r   A S   a r e a _ s u m _ h a 
 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 1 _ s t a _ m v i e w   A S   v g 
 W H E R E 	 g f = ' 3 '   O R   g f = ' 4 ' 
 U N I O N   A L L 
 S E L E C T 	 ' 6 '   : : i n t e g e r   A S   i d , 
 	 ' 1 _ s t a '   : : t e x t   A S   t a b l e , 
 	 ' w a t e r '   : : t e x t   A S   d e s c r i p t _ n a m e i o n , 
 	 S U M ( v g . a r e a _ h a )   : : i n t e g e r   A S   a r e a _ s u m _ h a 
 F R O M 	 p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 1 _ s t a _ m v i e w   A S   v g 
 W H E R E 	 g f = ' 1 '   O R   g f = ' 2 ' ; 
 
 - -   g r a n t   ( o e u s e r ) 
 A L T E R   T A B L E   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ s t a t i s t i c s _ m v i e w   O W N E R   T O   o e u s e r ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 1 0 ' , ' o u t p u t ' , ' p o l i t i c a l _ b o u n d a r y ' , ' b k g _ v g 2 5 0 _ s t a t i s t i c s _ m v i e w ' , ' e g o _ d p _ l o a d a r e a _ s t a t i s t i c . s q l ' , '   ' ) ; 
 
 
 - -   d r i d   d i s t r i c t 
 / *   S E L E C T 	 c o u n t ( g e o m ) 
 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ t y p e 1 
 W H E R E 	 g e o m   I S   N O T   N U L L ; 
 
 S E L E C T 	 c o u n t ( g e o m ) 
 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ t y p e 2 
 W H E R E 	 g e o m   I S   N O T   N U L L ; 
 
 S E L E C T 	 c o u n t ( g e o m ) 
 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ t y p e 3 
 W H E R E 	 g e o m   I S   N O T   N U L L ; 
 
 
 S E L E C T 	 c o u n t ( i d ) 
 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ h v m v _ s u b s t _ p e r _ g e m 
 W H E R E 	 s u b s t _ t y p e   =   ' 1 ' ; 
 
 S E L E C T 	 c o u n t ( i d ) 
 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ h v m v _ s u b s t _ p e r _ g e m 
 W H E R E 	 s u b s t _ t y p e   =   ' 2 ' ; 
 
 S E L E C T 	 c o u n t ( i d ) 
 F R O M 	 m o d e l _ d r a f t . e g o _ p o l i t i c a l _ b o u n d a r y _ h v m v _ s u b s t _ p e r _ g e m 
 W H E R E 	 s u b s t _ t y p e   =   ' 3 ' ;   * / 
 
 / *   - -   L A   S i z e s 
 S E L E C T 	 ' <   5   h a '   A S   n a m e , 
 	 c o u n t ( l a . g e o m ) : : i n t e g e r   A S   c o u n t , 
 	 c o u n t ( * ) : : d o u b l e   p r e c i s i o n   /   2 0 8 4 8 6   *   1 0 0   A S   s h a r e , 
 	 s u m ( l a . a r e a _ h a )   : : i n t e g e r   A S   a r e a 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a 
 W H E R E 	 a r e a _ h a   <   ' 5 ' 
 U N I O N   A L L 
 S E L E C T 	 ' >   5 0 0   h a '   A S   n a m e , 
 	 c o u n t ( l a . g e o m )   A S   c o u n t , 
 	 c o u n t ( l a . g e o m ) : : d o u b l e   p r e c i s i o n   /   2 0 8 4 8 6   *   1 0 0   A S   s h a r e , 
 	 s u m ( l a . a r e a _ h a )   : : i n t e g e r   A S   a r e a 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a 
 W H E R E 	 a r e a _ h a   >   ' 5 0 0 ' ;   * / 
 
 / *   
 - -   S c h n i t t l � n g e n   ( U m r i s s e ) 
 S E L E C T 	 ' R a w   L A '   A S   n a m e , 
 	 c o u n t ( l a . g e o m )   A S   n u m b e r , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m   
 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d _ m e l t   A S   l a 
 U N I O N   A L L 
 S E L E C T 	 ' L A / G D '   A S   n a m e , 
 	 c o u n t ( l a . g e o m )   A S   n u m b e r , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m   
 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a 
 U N I O N   A L L 
 S E L E C T 	 ' L A / V O I '   A S   n a m e , 
 	 c o u n t ( l a . g e o m )   A S   n u m b e r , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m   
 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a _ v o i   A S   l a ; 
   * / 
 
 / *   
 - -   T e i l   2 
 S E L E C T 	 ' R a w   L A '   A S   n a m e , 
 	 ' > 5 0 0   E W / k m 2 '   A S   P D , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a p d . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m 
 F R O M 	 ( S E L E C T 	 l a . i d , 
 	 	 l a . s u b s t _ i d , 
 	 	 g e m . p d _ k m 2 , 
 	 	 l a . a g s _ 0   A S   a g s _ 0 _ l a , 
 	 	 g e m . a g s _ 0   A S   a g s _ 0 _ g e m , 
 	 	 l a . g e o m 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d _ m e l t   A S   l a   J O I N   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ m v i e w   A S   g e m   O N   ( l a . a g s _ 0   =   g e m . a g s _ 0 ) 
 	 )   A S     l a p d 
 W H E R E 	 l a p d . p d _ k m 2   >   ' 5 0 0 ' 
 U N I O N   A L L 
 
 S E L E C T 	 ' L A / G D '   A S   n a m e , 
 	 ' > 5 0 0   E W / k m 2 '   A S   P D , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a p d . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m 
 F R O M 	 ( S E L E C T 	 l a . i d , 
 	 	 l a . s u b s t _ i d , 
 	 	 g e m . p d _ k m 2 , 
 	 	 l a . a g s _ 0   A S   a g s _ 0 _ l a , 
 	 	 g e m . a g s _ 0   A S   a g s _ 0 _ g e m , 
 	 	 l a . g e o m 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a   J O I N   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ m v i e w   A S   g e m   O N   ( l a . a g s _ 0   =   g e m . a g s _ 0 ) 
 	 )   A S     l a p d 
 W H E R E 	 l a p d . p d _ k m 2   >   ' 5 0 0 ' 
 U N I O N   A L L 
 S E L E C T 	 ' L A / G D '   A S   n a m e , 
 	 ' < 5 0 0   E W / k m 2 '   A S   P D , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a p d . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m 
 F R O M 	 ( S E L E C T 	 l a . i d , 
 	 	 l a . s u b s t _ i d , 
 	 	 g e m . p d _ k m 2 , 
 	 	 l a . a g s _ 0   A S   a g s _ 0 _ l a , 
 	 	 g e m . a g s _ 0   A S   a g s _ 0 _ g e m , 
 	 	 l a . g e o m 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a   A S   l a   J O I N   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ m v i e w   A S   g e m   O N   ( l a . a g s _ 0   =   g e m . a g s _ 0 ) 
 	 )   A S     l a p d 
 W H E R E 	 l a p d . p d _ k m 2   <   ' 5 0 0 ' 
 U N I O N   A L L 
 
 S E L E C T 	 ' L A / V O I '   A S   n a m e , 
 	 ' > 5 0 0   E W / k m 2 '   A S   P D , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a p d . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m 
 F R O M 	 ( S E L E C T 	 l a . i d , 
 	 	 l a . s u b s t _ i d , 
 	 	 g e m . p d _ k m 2 , 
 	 	 l a . a g s _ 0   A S   a g s _ 0 _ l a , 
 	 	 g e m . a g s _ 0   A S   a g s _ 0 _ g e m , 
 	 	 l a . g e o m 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a _ v o i   A S   l a   J O I N   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ m v i e w   A S   g e m   O N   ( l a . a g s _ 0   =   g e m . a g s _ 0 ) 
 	 )   A S     l a p d 
 W H E R E 	 l a p d . p d _ k m 2   >   ' 5 0 0 ' 
 U N I O N   A L L 
 S E L E C T 	 ' L A / V O I '   A S   n a m e , 
 	 ' < 5 0 0   E W / k m 2 '   A S   P D , 
 	 S T _ P e r i m e t e r ( S T _ C o l l e c t ( l a p d . g e o m ) ) / 1 0 0 0 0 0 0   A S   p e r i m e t e r _ i n _ t k m 
 F R O M 	 ( S E L E C T 	 l a . i d , 
 	 	 l a . s u b s t _ i d , 
 	 	 g e m . p d _ k m 2 , 
 	 	 l a . a g s _ 0   A S   a g s _ 0 _ l a , 
 	 	 g e m . a g s _ 0   A S   a g s _ 0 _ g e m , 
 	 	 l a . g e o m 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l o a d a r e a _ v o i   A S   l a   J O I N   p o l i t i c a l _ b o u n d a r y . b k g _ v g 2 5 0 _ 6 _ g e m _ m v i e w   A S   g e m   O N   ( l a . a g s _ 0   =   g e m . a g s _ 0 ) 
 	 )   A S     l a p d 
 W H E R E 	 l a p d . p d _ k m 2   <   ' 5 0 0 ' ;   * / 
 
 / *   n a m e ;   p d ;   p e r i m e t e r _ i n _ t k m 
 " L A / G D " ; " > 5 0 0   E W / k m 2 " ; 6 2 , 4 9 8 3 1 1 7 9 6 0 2 3 3 
 " L A / V O I " ; " > 5 0 0   E W / k m 2 " ; 6 3 , 6 1 3 9 3 1 7 0 4 7 5 6 5 
 
 " L A / G D " ; " < 5 0 0   E W / k m 2 " ; 3 1 2 , 9 0 1 7 8 7 6 2 8 6 9 1 
 " L A / V O I " ; " < 5 0 0   E W / k m 2 " ; 3 1 6 , 8 5 8 4 3 5 5 7 6 2 5 4 
 
 d e l t a _ L _ > 5 0 0   =   0 , 5 5 7 8 0 9 9 5 4 3 6 6 6   t k m 
 d e l t a _ L _ < 5 0 0   =   1 , 9 7 8 3 2 3 9 7 3 7 8 1 5   t k m 
 * / 
 
 
 / *   
 - -   s i m p l y t r y 
 D R O P   T A B L E   I F   E X I S T S   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e ; 
 C R E A T E   T A B L E   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e 
 ( 
     s u b s t _ i d   i n t e g e r   N O T   N U L L , 
     f a c t o r   t e x t , 
     g e o m   g e o m e t r y ( M u l t i P o l y g o n , 3 0 3 5 ) , 
     C O N S T R A I N T   e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e _ p k e y   P R I M A R Y   K E Y   ( s u b s t _ i d , f a c t o r ) 
 ) ; 
 
 I N S E R T   I N T O   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e 
 	 S E L E C T 	 g d . s u b s t _ i d , 
 	 	 ' 0 . 1 ' , 
 	 	 S T _ S i m p l i f y ( g d . g e o m , 0 . 1 ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   g d 
 	 W H E R E 	 g d . s u b s t _ i d   =   4 0 6   ; 
 
 I N S E R T   I N T O   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e 
 	 S E L E C T 	 g d . s u b s t _ i d , 
 	 	 ' 1 ' , 
 	 	 S T _ S i m p l i f y ( g d . g e o m , 1 ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   g d 
 	 W H E R E 	 g d . s u b s t _ i d   =   4 0 6   ; 
 
 I N S E R T   I N T O   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e 
 	 S E L E C T 	 g d . s u b s t _ i d , 
 	 	 ' 1 0 ' , 
 	 	 S T _ S i m p l i f y ( g d . g e o m , 1 0 ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   g d 
 	 W H E R E 	 g d . s u b s t _ i d   =   4 0 6   ; 
 
 I N S E R T   I N T O   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e 
 	 S E L E C T 	 g d . s u b s t _ i d , 
 	 	 ' 1 0 0 ' , 
 	 	 S T _ S i m p l i f y ( g d . g e o m , 1 0 0 ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   g d 
 	 W H E R E 	 g d . s u b s t _ i d   =   4 0 6   ; 
 
 I N S E R T   I N T O   m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ s i m p l e 
 	 S E L E C T 	 g d . s u b s t _ i d , 
 	 	 ' 1 0 0 0 ' , 
 	 	 S T _ S i m p l i f y ( g d . g e o m , 1 0 0 0 ) 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t   g d 
 	 W H E R E 	 g d . s u b s t _ i d   =   4 0 6   ; 
   * / 
 
 / *   - -   E W E   V a l i d a t i o n 
 
 - -   s u b s t a t i o n   i n   E W E       ( O K ! )   5 0 0 m s   = 1 3 6 
 D R O P   M A T E R I A L I Z E D   V I E W   I F   E X I S T S     	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ e w e _ m v i e w   C A S C A D E ; 
 C R E A T E   M A T E R I A L I Z E D   V I E W                   	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ e w e _ m v i e w   A S 
 	 S E L E C T 	 s u b s . * 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n   A S   s u b s , 
 	 	 m o d e l _ d r a f t . e g o _ g r i d _ m v _ g r i d d i s t r i c t _ e w e   A S   e w e 
 	 W H E R E     	 S T _ T R A N S F O R M ( e w e . g e o m , 3 0 3 5 )   & &   s u b s . g e o m   A N D 
 	 	 S T _ C O N T A I N S ( S T _ T R A N S F O R M ( e w e . g e o m , 3 0 3 5 ) , s u b s . g e o m )   ; 
 
 - -   i n d e x   G I S T   ( g e o m )       ( O K ! )   1 . 0 0 0 m s   = * 
 C R E A T E   I N D E X 	 e g o _ d e u _ s u b s t a t i o n s _ e w e _ m v i e w _ g e o m _ i d x 
 	 O N 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ e w e _ m v i e w 
 	 U S I N G 	 G I S T   ( g e o m ) ; 
 
 - -   G r a n t   o e u s e r       ( O K ! )   - >   1 0 0 m s   = * 
 G R A N T   A L L   O N   T A B L E 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ e w e _ m v i e w   T O   o e u s e r   W I T H   G R A N T   O P T I O N ; 
 A L T E R   T A B L E 	 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ e w e _ m v i e w   O W N E R   T O   o e u s e r ; 
 
 
 - -   S c e n a r i o   e G o   d a t a   p r o c e s s i n g 
 I N S E R T   I N T O 	 s c e n a r i o . e G o _ d a t a _ p r o c e s s i n g _ c l e a n _ r u n   ( v e r s i o n , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , e n t r i e s , s t a t u s , t i m e s t a m p ) 
 	 S E L E C T 	 ' 0 . 2 '   A S   v e r s i o n , 
 	 	 ' m o d e l _ d r a f t '   A S   s c h e m a _ n a m e , 
 	 	 ' e g o _ d e u _ s u b s t a t i o n s _ e w e _ m v i e w '   A S   t a b l e _ n a m e , 
 	 	 ' a n a l y s e _ e G o _ p a p e r _ r e s u l t . s q l '   A S   s c r i p t _ n a m e , 
 	 	 C O U N T ( * ) A S   e n t r i e s , 
 	 	 ' O K '   A S   s t a t u s , 
 	 	 N O W ( )   A T   T I M E   Z O N E   ' E u r o p e / B e r l i n '   A S   t i m e s t a m p 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ g r i d _ h v m v _ s u b s t a t i o n _ e w e _ m v i e w ;   * / 
 	 
 	 
 