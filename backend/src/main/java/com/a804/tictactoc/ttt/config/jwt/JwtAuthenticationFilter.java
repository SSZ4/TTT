package com.a804.tictactoc.ttt.config.jwt;

import com.a804.tictactoc.ttt.config.FirebaseAuthenticationToken;

import com.a804.tictactoc.ttt.request.LoginReq;

import com.a804.tictactoc.ttt.service.UserService;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;

import lombok.RequiredArgsConstructor;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;

import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import java.util.Date;

import java.util.concurrent.TimeUnit;



@RequiredArgsConstructor
public class JwtAuthenticationFilter extends UsernamePasswordAuthenticationFilter  {

    //컬렉션 네임 생성
    public static final String COLLECTION_NAME = "users";


    private final AuthenticationManager authenticationManager;
    //스프링과 레디스 사이에서 쓰레드 세이프한 브리지를 제공해 주는 역할
    private final RedisTemplate<String, Object> redisTemplate;

    private final FirebaseAuth firebaseAuth;

    private final UserService userService;

    private final PrincipalDetailsService principalDetailsService;



    /**
     인증 요청 시 실행되는 함수 (/login)
     */
    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
            throws AuthenticationException {

        /*
        여기서 프론트가 준 ID TOKEN을 가지고
        구글에 유저 정보를 요청한다(userid)
        */
        /*
        1. id token 받는다.
        2. 그거 기반 uid를 갖고와서 유저 이메일을 갖고와
        3. 그거 토대로 select, null이면 insert

        1. 로그인 api
        * */
        // request에 있는 username과 password를 java Object로 받기

        ObjectMapper om = new ObjectMapper();
        LoginReq loginReq = null;
        try{
            loginReq = om.readValue(request.getInputStream(), LoginReq.class);
        }catch(Exception e){
            e.printStackTrace();
        }

        String tokenId = loginReq.getIdToken();
        //여기서 유저 uid를 받는다.
        FirebaseToken decodedToken = null;
        try {
            decodedToken = firebaseAuth.getInstance().verifyIdToken(tokenId);
        } catch (FirebaseAuthException e) {
            throw new RuntimeException(e);
        }
        String uid = decodedToken.getUid();
        System.out.println(uid);

        /*
        //uid를 기반으로 유저 정보를 가져온다. 필요시 사용
        UserRecord userRecord = firebaseAuth.getUser(uid);
        String email = userRecord.getEmail();
        String displayName = userRecord.getDisplayName();
        */
        //idtoken 만료 이슈 때문에 uid를 test로 받아놓음
        //String uid = "fk9AqAXtRjXyBJIPD6wFDqcXlHs1";
        userService.login(uid);

        //여기서 파이어베이스에 접근해서 유저 아이디를 가져와야됨
        //유저네임패스워드 토큰 생성

        FirebaseAuthenticationToken authenticationToken = new FirebaseAuthenticationToken(principalDetailsService.loadUserByUsername(uid));
        return authenticationToken;
    }
    /**
     Authentication 객체가 성공적으로 만들어지면 JWT Token 생성해서 response에 담기
     */
    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain,
                                            Authentication authResult) throws IOException, ServletException {


        PrincipalDetails principalDetailis = (PrincipalDetails) authResult.getPrincipal();
        PrincipalDetailInfo.staticPrincipalDetailis = principalDetailis;
        String accessToken = JWT.create()
                .withSubject(principalDetailis.getUsername())
                .withExpiresAt(new Date(System.currentTimeMillis()+JwtProperties.ACCESS_EXPIRATION_TIME))
                .withClaim("uid", principalDetailis.getUser().getUid())
                .sign(Algorithm.HMAC512(JwtProperties.SECRET));

        String refreshToken = JWT.create()
                .withSubject(principalDetailis.getUsername())
                .withExpiresAt(new Date(System.currentTimeMillis()+JwtProperties.REFRESH_EXPIRATION_TIME))
                .withClaim("uid", principalDetailis.getUser().getUid())
                .sign(Algorithm.HMAC512(JwtProperties.SECRET));
        //RefreshToken을 Redis에 저장 (expirationTime 설정을 통해 자동 삭제 처리)
        redisTemplate.opsForValue()
                .set("RT:" + principalDetailis.getUsername(), refreshToken, JwtProperties.REFRESH_EXPIRATION_TIME, TimeUnit.MILLISECONDS);
        redisTemplate.opsForValue()
                .set("AT:" + principalDetailis.getUsername(), accessToken, JwtProperties.ACCESS_EXPIRATION_TIME, TimeUnit.MILLISECONDS);

        String jwtToken = JwtProperties.TOKEN_PREFIX+accessToken + "_AND_" + JwtProperties.TOKEN_PREFIX+refreshToken;

        String access = JwtProperties.TOKEN_PREFIX+accessToken;
        String refresh = JwtProperties.TOKEN_PREFIX+refreshToken;
        response.setHeader(JwtProperties.ACCESS_HEADER, access);
        response.setHeader(JwtProperties.REFRESH_HEADER, refresh);


    }
}