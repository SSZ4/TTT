package com.a804.tictactoc.ttt.controller;

import com.a804.tictactoc.ttt.db.entity.User;
import com.a804.tictactoc.ttt.request.TickleReq;
import com.a804.tictactoc.ttt.response.*;
import com.a804.tictactoc.ttt.service.TickleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springdoc.api.annotations.ParameterObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.sql.SQLException;
import java.util.List;


@Tag(name = "티끌", description = "티끌 api 입니다.")
@RestController
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequestMapping("/tickle")
@RequiredArgsConstructor
public class TickleController {
	
	private static final Logger logger = LoggerFactory.getLogger(TickleController.class);

	@Autowired
	TickleService tService;

	private ResponseEntity<String> exceptionHandling(Exception e) {
		e.printStackTrace();
		return new ResponseEntity<String>("Sorry: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@Operation(summary = "티끌 읽기", description = "해당 티끌의 정보를 가져옵니다.",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 읽기 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@GetMapping(value = "/{tickleId}")
	public ResponseEntity<?> readTickle(@PathVariable long tickleId, HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();//임시
		TickleRes result = tService.readTickle(tickleId);
		return new ResponseEntity<TickleRes>(result, HttpStatus.OK);
	}

	@Operation(summary = "티끌 생성", description = "유저가 티끌을 생성합니다.",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 변경 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@PostMapping(value = "")
	public ResponseEntity<?> createTickle(@RequestBody TickleReq tickleReq, HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();//임시
		TickleRes tickleRes = tService.createTickle(userId, tickleReq);

		if(tickleRes == null)
			return new ResponseEntity<Void>(HttpStatus.UNAUTHORIZED);

		return new ResponseEntity<TickleRes>(tickleRes, HttpStatus.OK);
	}

	@Operation(summary = "오늘, 미래의 일정 가져오기", description = "오늘, 미래에 수행해야 할 일정들의 정보를 가져옵니다",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 읽기 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@GetMapping(value = "/schedule")
	public ResponseEntity<?> readTodaySchedule(String targetDate, HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();
		List<TickleCategoryRes> result = tService.todaySchedule(userId, targetDate);
		return new ResponseEntity<List<TickleCategoryRes>>(result, HttpStatus.OK);
	}

	@Operation(summary = "과거 티끌들 가져오기", description = "과거에 생성한 티끌들의 정보를 가져옵니다",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 읽기 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@GetMapping(value = "/past")
	public ResponseEntity<?> readPastTickle(String targetDate, HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();
		List<TickleCategoryPastRes> result = tService.pastTickles(userId, targetDate);
		return new ResponseEntity<List<TickleCategoryPastRes>>(result, HttpStatus.OK);
	}

	@Operation(summary = "한달치 티끌 수행 여부", description = "지정한 달에 각 날짜에 티끌을 생성한 적이 있는지를 반환합니다.",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 읽기 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@GetMapping(value = "/month")
	public ResponseEntity<?> readMonthTickles(String targetDate, HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();
		List<String> result = tService.monthTickleAchieve(userId, targetDate);
		return new ResponseEntity<List<String>>(result, HttpStatus.OK);
	}
	

	@Operation(summary = "카테고리별 티끌 개수", description = "각 카테고리별 티끌의 개수를 가져온다",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 읽기 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@GetMapping(value = "/count")
	public ResponseEntity<?> countTickleByCategory(HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();
		List<TickleCountRes> result = tService.countTickle(userId);
		return new ResponseEntity<List<TickleCountRes>>(result, HttpStatus.OK);
	}

	@Operation(summary = "티끌 삭제", description = "해당 번호의 티끌을 삭제한다",
			responses = {
					@ApiResponse(responseCode = "200", description = "습관 읽기 성공"),
					@ApiResponse(responseCode = "500", description = "서버 오류") })
	@DeleteMapping(value = "/delete")
	public ResponseEntity<?> deleteTickle(@RequestBody TickleReq tickleReq, HttpServletRequest request) throws Exception{
		User user = (User) request.getAttribute("USER");
		long userId = user.getId();
		tService.deleteTickle(userId, tickleReq);
		return new ResponseEntity<Void>(HttpStatus.OK);
	}


	@ExceptionHandler(SQLException.class)
	@ResponseStatus(value = HttpStatus.BAD_REQUEST, reason = "유효하지 않은 입력 값")
	public void sqlException() {
		System.out.println("SQLException 발생");
		return;
	}

}