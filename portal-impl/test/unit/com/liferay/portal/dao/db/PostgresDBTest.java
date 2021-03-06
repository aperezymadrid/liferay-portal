/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.portal.dao.db;

import com.liferay.portal.kernel.dao.db.DB;

import java.io.IOException;

import org.junit.Assert;
import org.junit.Test;

/**
 * @author Miguel Pastor
 */
public class PostgresDBTest extends BaseDBTestCase {

	@Test
	public void testRewordRenameTable() throws IOException {
		Assert.assertEquals(
			"alter table a rename to b;\n", buildSQL(RENAME_TABLE_QUERY));
	}

	@Override
	protected DB getDB() {
		return PostgreSQLDB.getInstance();
	}

}