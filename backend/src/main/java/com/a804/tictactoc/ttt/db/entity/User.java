package com.a804.tictactoc.ttt.db.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

/**
 * 유저 모델 정의.
 */
@Entity
@Table(name="user")
@DynamicInsert
@DynamicUpdate
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class User{

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Schema(hidden = true)
	long id;

	@Schema(name = "유저의 uid", example = "fk9AqAXtRjXyBJIPD6wFDqcXlHs1", defaultValue = "fk9AqAXtRjXyBJIPD6wFDqcXlHs1")
	@Column(name="uid")
	String uid;

	@Schema(name = "방해금지 시작 시간 HHmm", example = "2330", defaultValue = "2330")
	@Column(name="sleep_start_time")
	String sleepStartTime;

	@Schema(name = "방해금지 끝 시간 HHmm", example = "0730", defaultValue = "0730")
	@Column(name="sleep_end_time")
	String sleepEndTime;

	@Schema(hidden = true)
	@Column(name="delete_yn")
	int deleteYn;

	@Schema(hidden = true)
	@Column(name="created_date")
	String createdDate;

	@Schema(hidden = true)
	@Column(name="modified_date")
	String modifiedDate;
}

