/ * 
 c e n s u s   2 0 1 1   p o p u l a t i o n   p e r   h a   
 I d e n t i f y   p o p u l a t i o n   i n   o s m   l o a d s 
 
 _ _ c o p y r i g h t _ _   	 =   " R e i n e r   L e m o i n e   I n s t i t u t   g G m b H " 
 _ _ l i c e n s e _ _   	 =   " G N U   A f f e r o   G e n e r a l   P u b l i c   L i c e n s e   V e r s i o n   3   ( A G P L - 3 . 0 ) " 
 _ _ u r l _ _   	 =   " h t t p s : / / g i t h u b . c o m / o p e n e g o / d a t a _ p r o c e s s i n g / b l o b / m a s t e r / L I C E N S E " 
 _ _ a u t h o r _ _   	 =   " L u d e e " 
 * / 
 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 5 ' , ' i n p u t ' , ' s o c i a l ' , ' d e s t a t i s _ z e n s u s _ p o p u l a t i o n _ p e r _ h a _ m v i e w ' , ' s e t u p _ z e n s u s _ p o p u l a t i o n _ p e r _ h a . s q l ' , '   ' ) ; 
 
 - -   z e n s u s   l o a d 
 D R O P   T A B L E   I F   E X I S T S     	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   C A S C A D E ; 
 C R E A T E   T A B L E                   	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   ( 
 	 i d   	 	 S E R I A L   N O T   N U L L , 
 	 g i d   	 	 i n t e g e r , 
 	 p o p u l a t i o n   	 i n t e g e r , 
 	 i n s i d e _ l a   	 b o o l e a n , 
 	 g e o m _ p o i n t   	 g e o m e t r y ( P o i n t , 3 0 3 5 ) , 
 	 g e o m   	 	 g e o m e t r y ( P o l y g o n , 3 0 3 5 ) , 
 	 C O N S T R A I N T   e g o _ d e m a n d _ l a _ z e n s u s _ p k e y   P R I M A R Y   K E Y   ( i d ) ) ; 
 
 - -   i n s e r t   z e n s u s   l o a d s 
 I N S E R T   I N T O 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   ( g i d , p o p u l a t i o n , i n s i d e _ l a , g e o m _ p o i n t , g e o m ) 
 	 S E L E C T 	 z e n s u s . g i d   : : i n t e g e r , 
 	 	 z e n s u s . p o p u l a t i o n   : : i n t e g e r , 
 	 	 ' F A L S E '   : : b o o l e a n   A S   i n s i d e _ l a , 
 	 	 z e n s u s . g e o m _ p o i n t   : : g e o m e t r y ( P o i n t , 3 0 3 5 ) , 
 	 	 z e n s u s . g e o m   : : g e o m e t r y ( P o l y g o n , 3 0 3 5 ) 
 	 F R O M 	 s o c i a l . d e s t a t i s _ z e n s u s _ p o p u l a t i o n _ p e r _ h a _ m v i e w   A S   z e n s u s ; 
 
 - -   i n d e x   g i s t   ( g e o m _ p o i n t ) 
 C R E A T E   I N D E X     	 e g o _ d e m a n d _ l a _ z e n s u s _ g e o m _ p o i n t _ i d x 
 	 O N 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   U S I N G   G I S T   ( g e o m _ p o i n t ) ; 
 
 - -   i n d e x   g i s t   ( g e o m ) 
 C R E A T E   I N D E X     	 e g o _ d e m a n d _ l a _ z e n s u s _ g e o m _ i d x 
 	 O N 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   U S I N G   G I S T   ( g e o m ) ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 5 ' , ' i n p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ d e m a n d _ l a _ o s m ' , ' s e t u p _ z e n s u s _ p o p u l a t i o n _ p e r _ h a . s q l ' , '   ' ) ; 
 	 
 - -   p o p u l a t i o n   i n   o s m   l o a d s 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   A S   t 1 
 	 S E T     	 i n s i d e _ l a   =   t 2 . i n s i d e _ l a 
 	 F R O M         ( 
 	 	 S E L E C T 	 z e n s u s . i d   A S   i d , 
 	 	 	 ' T R U E '   : : b o o l e a n   A S   i n s i d e _ l a 
 	 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   A S   z e n s u s , 
 	 	 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ o s m   A S   o s m 
 	 	 W H E R E     	 o s m . g e o m   & &   z e n s u s . g e o m _ p o i n t   A N D 
 	 	 	 S T _ C O N T A I N S ( o s m . g e o m , z e n s u s . g e o m _ p o i n t ) 
 	 	 )   A S   t 2 
 	 W H E R E     	 t 1 . i d   =   t 2 . i d ; 
 
 - -   r e m o v e   i d e n t i f i e d   p o p u l a t i o n 
 D E L E T E   F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   A S   l p 
 	 W H E R E 	 l p . i n s i d e _ l a   I S   T R U E ; 
 
 - -   g r a n t   ( o e u s e r ) 
 A L T E R   T A B L E 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   O W N E R   T O   o e u s e r ; 	 
 
 - -   m e t a d a t a 
 C O M M E N T   O N   T A B L E   m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   I S   ' { 
         " N a m e " :   " e g o   z e n s u s   l o a d s " , 
         " S o u r c e " :       [ { 
 	 " N a m e " :   " o p e n _ e G o " , 
 	 " U R L " :   " h t t p s : / / g i t h u b . c o m / o p e n e g o / d a t a _ p r o c e s s i n g " } ] , 
         " R e f e r e n c e   d a t e " :   " 2 0 1 6 " , 
         " D a t e   o f   c o l l e c t i o n " :   " 0 2 . 0 9 . 2 0 1 6 " , 
         " O r i g i n a l   f i l e " :   [ " e g o _ g r i d _ h v m v _ s u b s t a t i o n " ] , 
         " S p a t i a l " :   [ { 
 	 " R e s o l u t i o n " :   " " , 
 	 " E x t e n d " :   " G e r m a n y "   } ] , 
         " D e s c r i p t i o n " :   [ " o s m   l a o d s " ] , 
         " C o l u m n " : [ 
                 { " N a m e " :   " i d " ,   " D e s c r i p t i o n " :   " U n i q u e   i d e n t i f i e r " ,   " U n i t " :   "   "   } , 
                 { " N a m e " :   " a r e a _ h a " ,   " D e s c r i p t i o n " :   " A r e a " ,   " U n i t " :   " h a "   } , 
 	 { " N a m e " :   " g e o m " ,   " D e s c r i p t i o n " :   " G e o m e t r y " ,   " U n i t " :   "   "   }   ] , 
         " C h a n g e s " : 	 [ 
                 { " N a m e " :   " L u d w i g   H � l k " ,   " M a i l " :   " l u d w i g . h u e l k @ r l - i n s t i t u t . d e " , 
 	 " D a t e " :     " 0 2 . 0 9 . 2 0 1 5 " ,   " C o m m e n t " :   " C r e a t e d   m v i e w "   } , 
 	 { " N a m e " :   " L u d w i g   H � l k " ,   " M a i l " :   " l u d w i g . h u e l k @ r l - i n s t i t u t . d e " , 
 	 " D a t e " :     " 1 7 . 1 2 . 2 0 1 6 " ,   " C o m m e n t " :   " A d d e d   m e t a d a t a "   }   ] , 
         " N o t e s " :   [ " " ] , 
         " L i c e n c e " :   [ { 
 	 " N a m e " :   " " ,   
 	 " U R L " :   " "   } ] , 
         " I n s t r u c t i o n s   f o r   p r o p e r   u s e " :   [ "   " ] 
         } '   ; 
 
 - -   s e l e c t   d e s c r i p t i o n 
 S E L E C T   o b j _ d e s c r i p t i o n ( ' m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s '   : : r e g c l a s s )   : : j s o n ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 5 ' , ' o u t p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ d e m a n d _ l a _ z e n s u s ' , ' s e t u p _ z e n s u s _ p o p u l a t i o n _ p e r _ h a . s q l ' , '   ' ) ; 
 
 
 - -   c l u s t e r   f r o m   z e n s u s   l o a d   l a t t i c e 
 D R O P   T A B L E   I F   E X I S T S 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   C A S C A D E ; 
 C R E A T E   T A B L E                   	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   ( 
 	 c i d   s e r i a l , 
 	 z e n s u s _ s u m   I N T , 
 	 a r e a _ h a   I N T , 
 	 g e o m   g e o m e t r y ( P o l y g o n , 3 0 3 5 ) , 
 	 g e o m _ b u f f e r   g e o m e t r y ( P o l y g o n , 3 0 3 5 ) , 
 	 g e o m _ c e n t r o i d   g e o m e t r y ( P o i n t , 3 0 3 5 ) , 
 	 g e o m _ s u r f a c e p o i n t   g e o m e t r y ( P o i n t , 3 0 3 5 ) , 
 	 C O N S T R A I N T   e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r _ p k e y   P R I M A R Y   K E Y   ( c i d ) ) ; 
 
 - -   i n s e r t   c l u s t e r 
 I N S E R T   I N T O 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r ( g e o m ) 
 	 S E L E C T 	 ( S T _ D U M P ( S T _ M U L T I ( S T _ U N I O N ( g r i d . g e o m ) ) ) ) . g e o m   : : g e o m e t r y ( P o l y g o n , 3 0 3 5 )   A S   g e o m 
 	 F R O M         m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   A S   g r i d ; 
 
 - -   i n d e x   g i s t   ( g e o m ) 
 C R E A T E   I N D E X 	 e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r _ g e o m _ i d x 
 	 O N   	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   U S I N G   G I S T   ( g e o m ) ; 
 
 - -   c l u s t e r   d a t a 
 U P D A T E   	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   A S   t 1 
 	 S E T     	 z e n s u s _ s u m   =   t 2 . z e n s u s _ s u m , 
 	 	 a r e a _ h a   =   t 2 . a r e a _ h a , 
 	 	 g e o m _ b u f f e r   =   t 2 . g e o m _ b u f f e r , 
 	 	 g e o m _ c e n t r o i d   =   t 2 . g e o m _ c e n t r o i d , 
 	 	 g e o m _ s u r f a c e p o i n t   =   t 2 . g e o m _ s u r f a c e p o i n t 
 	 F R O M         ( 
 	 	 S E L E C T 	 c l . c i d   A S   c i d , 
 	 	 	 S U M ( l p . p o p u l a t i o n )   A S   z e n s u s _ s u m , 
 	 	 	 C O U N T ( l p . g e o m )   A S   a r e a _ h a , 
 	 	 	 S T _ B U F F E R ( c l . g e o m ,   1 0 0 )   A S   g e o m _ b u f f e r , 
 	 	 	 S T _ C e n t r o i d ( c l . g e o m )   A S   g e o m _ c e n t r o i d , 
 	 	 	 S T _ P o i n t O n S u r f a c e ( c l . g e o m )   A S   g e o m _ s u r f a c e p o i n t 
 	 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s   A S   l p , 
 	 	 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   A S   c l 
 	 	 W H E R E     	 c l . g e o m   & &   l p . g e o m   A N D 
 	 	 	 S T _ C O N T A I N S ( c l . g e o m , l p . g e o m ) 
 	 	 G R O U P   B Y 	 c l . c i d 
 	 	 O R D E R   B Y 	 c l . c i d 
 	 	 )   A S   t 2 
 	 W H E R E     	 t 1 . c i d   =   t 2 . c i d ; 
 
 - -   i n d e x   g i s t   ( g e o m _ c e n t r o i d ) 
 C R E A T E   I N D E X 	 e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r _ g e o m _ c e n t r o i d _ i d x 
 	 O N 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   U S I N G   G I S T   ( g e o m _ c e n t r o i d ) ; 
 
 - -   i n d e x   g i s t   ( g e o m _ s u r f a c e p o i n t ) 
 C R E A T E   I N D E X 	 e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r _ g e o m _ s u r f a c e p o i n t _ i d x 
 	 O N 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   U S I N G   G I S T   ( g e o m _ s u r f a c e p o i n t ) ; 
 
 - -   g r a n t   ( o e u s e r ) 
 A L T E R   T A B L E 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   O W N E R   T O   o e u s e r ; 
 
 - -   m e t a d a t a 
 C O M M E N T   O N   T A B L E   m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r   I S   ' { 
         " N a m e " :   " e g o   z e n s u s   l o a d s   c l u s t e r " , 
         " S o u r c e " :       [ { 
 	 " N a m e " :   " o p e n _ e G o " , 
 	 " U R L " :   " h t t p s : / / g i t h u b . c o m / o p e n e g o / d a t a _ p r o c e s s i n g " } ] , 
         " R e f e r e n c e   d a t e " :   " 2 0 1 6 " , 
         " D a t e   o f   c o l l e c t i o n " :   " 0 2 . 0 9 . 2 0 1 6 " , 
         " O r i g i n a l   f i l e " :   [ " e g o _ g r i d _ h v m v _ s u b s t a t i o n " ] , 
         " S p a t i a l " :   [ { 
 	 " R e s o l u t i o n " :   " " , 
 	 " E x t e n d " :   " G e r m a n y "   } ] , 
         " D e s c r i p t i o n " :   [ " o s m   l a o d s " ] , 
         " C o l u m n " : [ 
                 { " N a m e " :   " i d " ,   " D e s c r i p t i o n " :   " U n i q u e   i d e n t i f i e r " ,   " U n i t " :   "   "   } , 
                 { " N a m e " :   " a r e a _ h a " ,   " D e s c r i p t i o n " :   " A r e a " ,   " U n i t " :   " h a "   } , 
 	 { " N a m e " :   " g e o m " ,   " D e s c r i p t i o n " :   " G e o m e t r y " ,   " U n i t " :   "   "   }   ] , 
         " C h a n g e s " : 	 [ 
                 { " N a m e " :   " L u d w i g   H � l k " ,   " M a i l " :   " l u d w i g . h u e l k @ r l - i n s t i t u t . d e " , 
 	 " D a t e " :     " 0 2 . 0 9 . 2 0 1 5 " ,   " C o m m e n t " :   " C r e a t e d   m v i e w "   } , 
 	 { " N a m e " :   " L u d w i g   H � l k " ,   " M a i l " :   " l u d w i g . h u e l k @ r l - i n s t i t u t . d e " , 
 	 " D a t e " :     " 1 7 . 1 2 . 2 0 1 6 " ,   " C o m m e n t " :   " A d d e d   m e t a d a t a "   }   ] , 
         " N o t e s " :   [ " " ] , 
         " L i c e n c e " :   [ { 
 	 " N a m e " :   " " ,   
 	 " U R L " :   " "   } ] , 
         " I n s t r u c t i o n s   f o r   p r o p e r   u s e " :   [ "   " ] 
         } '   ; 
 
 - -   s e l e c t   d e s c r i p t i o n 
 S E L E C T   o b j _ d e s c r i p t i o n ( ' m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r '   : : r e g c l a s s )   : : j s o n ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 5 ' , ' o u t p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r ' , ' s e t u p _ z e n s u s _ p o p u l a t i o n _ p e r _ h a . s q l ' , '   ' ) ; 
 
 
 - -   z e n s u s   s t a t s 
 D R O P   M A T E R I A L I Z E D   V I E W   I F   E X I S T S 	 m o d e l _ d r a f t . e g o _ s o c i a l _ z e n s u s _ p e r _ l a _ m v i e w   C A S C A D E ; 
 C R E A T E   M A T E R I A L I Z E D   V I E W                   	 m o d e l _ d r a f t . e g o _ s o c i a l _ z e n s u s _ p e r _ l a _ m v i e w   A S 
 	 S E L E C T   	 ' d e s t a t i s _ z e n s u s _ p o p u l a t i o n _ p e r _ h a _ m v i e w '   A S   n a m e , 
 	 	 s u m ( p o p u l a t i o n ) ,   
 	 	 c o u n t ( g e o m )   A S   c e n s u s _ c o u n t 
 	 F R O M 	 s o c i a l . d e s t a t i s _ z e n s u s _ p o p u l a t i o n _ p e r _ h a _ m v i e w 
 	 U N I O N   A L L   
 	 S E L E C T   	 ' e g o _ d e m a n d _ l a _ z e n s u s '   A S   n a m e , 
 	 	 s u m ( p o p u l a t i o n ) ,   
 	 	 c o u n t ( g e o m )   A S   c e n s u s _ c o u n t 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s 
 	 U N I O N   A L L   
 	 S E L E C T   	 ' e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r '   A S   n a m e , 
 	 	 s u m ( z e n s u s _ s u m ) ,   
 	 	 c o u n t ( g e o m )   A S   c e n s u s _ c o u n t 
 	 F R O M 	 m o d e l _ d r a f t . e g o _ d e m a n d _ l a _ z e n s u s _ c l u s t e r ; 
 
 - -   g r a n t   ( o e u s e r ) 
 A L T E R   T A B L E 	 m o d e l _ d r a f t . e g o _ s o c i a l _ z e n s u s _ p e r _ l a _ m v i e w   O W N E R   T O   o e u s e r ; 
 
 - -   e g o   s c e n a r i o   l o g   ( v e r s i o n , i o , s c h e m a _ n a m e , t a b l e _ n a m e , s c r i p t _ n a m e , c o m m e n t ) 
 S E L E C T   e g o _ s c e n a r i o _ l o g ( ' v 0 . 2 . 5 ' , ' o u t p u t ' , ' m o d e l _ d r a f t ' , ' e g o _ s o c i a l _ z e n s u s _ p e r _ l a _ m v i e w ' , ' s e t u p _ z e n s u s _ p o p u l a t i o n _ p e r _ h a . s q l ' , '   ' ) ; 
 