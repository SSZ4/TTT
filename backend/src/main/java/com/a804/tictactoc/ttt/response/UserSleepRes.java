package com.a804.tictactoc.ttt.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 유저 모델 정의.
 */
@Schema(name="UserSleepRes")
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserSleepRes {
	@Schema(name = "sleepStartTime", description = "방해 금지 시작 시간", example = "2330", defaultValue = "2330")
	String sleepStartTime;

	@Schema(name = "sleepEndTime", description = "방해 금지 끝 시간", example = "0800", defaultValue = "0800")
	String sleepEndTime;
}
